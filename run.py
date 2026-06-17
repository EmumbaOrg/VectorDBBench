#run.py
import argparse
import time
import subprocess
import os
import logging
from contextlib import redirect_stdout
from benchmark_run_utils import *

logger = logging.getLogger(__file__)
logger.setLevel(logging.DEBUG)
handler = logging.StreamHandler()
handler.setLevel(logging.DEBUG)
formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)

os.environ["LOG_LEVEL"] = "DEBUG"

def main():
    parser = argparse.ArgumentParser(description="Run benchmarks on a large dataset using multiple configurations.")
    parser.add_argument("--dry-run", action="store_true", help="Print commands and output directory without executing")
    parser.add_argument("--config", default="config.json", help="Path to config JSON file (default: config.json)")
    parser.add_argument("--config-dir-path", type=str, help="Path to the config files directory.")
    args = parser.parse_args()

    if args.config_dir_path:
        # Handle config directory mode - iterate over all config files
        run_with_config_dir(args.config_dir_path, args.dry_run)
    else:
        # Handle single config file mode (existing behavior)
        run_with_single_config(args.config, args.dry_run)


def run_with_config_dir(config_dir_path: str, dry_run: bool = False):
    """Run benchmarks using all config files in the specified directory.
    
    Args:
        config_dir_path: Path to directory containing config files.
        dry_run: If True, print commands without executing.
    """
    for dir_path, _, file_names in os.walk(config_dir_path):
        for file_name in file_names:
            config = load_config(os.path.join(dir_path, file_name))
            benchmark_info = config.get("benchmark-info", {})
            start_time = time.time()
            start_timeh = time.strftime('%Y-%m-%d %H:%M:%S')
            logger.info(f"Benchmark run start time: {start_timeh} for config: {file_name}")

            for case in config['cases']:
                logger.info(f"Running case: {case['db-label']}")
                setup_database(config)
                run_benchmark(case, config['database'], benchmark_info, dry_run)
                teardown_database(config)

            end_time = time.time()
            end_timeh = time.strftime('%Y-%m-%d %H:%M:%S')
            execution_time = end_time - start_time

            if not dry_run:
                output_dir = get_output_dir_path(case, benchmark_info, [], 0, db_config=config['database'], base_dir=True)
                generate_benchmark_metadata(config, start_timeh, end_timeh, output_dir)

            logger.info(f"Benchmark run end time: {end_timeh}")
            logger.info(f"COMPLETED ALL EXECUTIONS of config {file_name}. total_duration={execution_time}")


def run_with_single_config(config_path: str = "config.json", dry_run: bool = False):
    """Run benchmarks using the default config.json file."""
    config = load_config(config_path)
    benchmark_info = config["benchmark-info"]
    start_time = time.time()
    start_timeh = time.strftime('%Y-%m-%d %H:%M:%S')
    logger.info(f"Benchmark run start time: {start_timeh}")
    for case in config['cases']:
        print(f"Running case: {case['db-label']}")
        setup_database(config)
        run_benchmark(case, config['database'], config["benchmark-info"], dry_run)
        teardown_database(config)
    end_timeh = time.strftime('%Y-%m-%d %H:%M:%S')
    if not dry_run:
        output_dir = get_output_dir_path(case, benchmark_info, [], 0, db_config=config['database'], base_dir=True)
        generate_benchmark_metadata(config, start_timeh, end_timeh, output_dir)

    end_time = time.time()
    execution_time = end_time - start_time
    logger.info(f"Benchmark run end time: {end_timeh}")
    logger.info(f"COMPLETED ALL EXECUTIONS. total_duration={execution_time}")

def run_benchmark(case, db_config, benchmark_info, dry_run=False):
    base_command = get_base_command(case, db_config)
    run_count = case.get("run-count", 1)  # Default to 1 if not specified
    for run in range(run_count):
        print(f"Starting run {run + 1} of {run_count} for case: {case['db-label']}")
        for i, search_params in enumerate(generate_combinations(case["search-params"])):
            command = base_command + search_params
            if case["index-type"] == "hnsw-bq" and "reranking" in case:
                if case.get("half-quantized-fetch-limit", False):
                    command += ["--quantized-fetch-limit", str(int(int(search_params[1]) / 2))]
                else:
                    command += ["--quantized-fetch-limit", search_params[1]]

            if i > 0 or run > 0:
                command = handle_drop_old_load_flags(command)

            if dry_run:
                logger.info(f"Command: {' '.join(command)}")
                logger.info(f"Output Dir: {get_output_dir_path(case, benchmark_info, search_params, run, db_config)}")
                logger.info(f"Extra Information: {get_extension_version(db_config)} \n")
            else:
                try:
                    output_dir = get_output_dir_path(case, benchmark_info, search_params, run, db_config)
                    os.environ["RESULTS_LOCAL_DIR"] = output_dir
                    os.environ["EXPLAIN_ANALYZE_LOG_FILE"] = os.path.join(output_dir, "explain_analyze.log")
                    os.makedirs(output_dir, exist_ok=True)

                    with open(f"{output_dir}/log.txt", 'w') as f:
                        print_configuration(case, benchmark_info, db_config, command, f)
                        run_pre_warm(db_config, case)
                        f.flush()

                        logger.info("***********START***********")
                        start_time = time.time()
                        # Capture both stdout and stderr and write them to the log file
                        subprocess.run(command, check=True, stdout=f, stderr=f)
                        end_time = time.time()
                        execution_time = end_time - start_time
                        logger.info(f"total_duration={execution_time}")
                        logger.info("***********END***********")

                        with redirect_stdout(f):
                            get_stats(db_config)
                            f.flush()
                        f.flush()

                    # Print output directory at the end with clickable link
                    logger.info(f"Results saved to:")
                    logger.info(f"   file://{os.path.abspath(output_dir)}")
                    logger.info("=" * 40)

                except subprocess.CalledProcessError as e:
                    logger.error(f"Benchmark Failed: {e}")
                logger.info("Sleeping for 1 min")
                time.sleep(60)

if __name__ == "__main__":
    main()

