#run.py
import argparse
import time
import subprocess
import os
import logging
import shutil
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


def create_dataset(args: dict) -> bool:
    """
    This function creates a dataset from the original dataset using script
    create_dataset_subsets.py and pass required arguments to it.
    """
    file_count = args.get("file-count")
    is_shuffled = args.get("is-shuffled")
    directory = args.get("directory")
    output_dir = args.get("save-dir-path")

    try:
        # Define the command to run the create_dataset_subsets.py script
        command = [
            "python3", "create_dataset_subsets.py",
            "--directory", directory,
            "--save-dir-path", output_dir,
            "--file-count", str(file_count),
        ]
        logger.info(f"Running command: {' '.join(command)}")

        file_prefix = "train"
        if is_shuffled:
            file_prefix = "shuffle_train"
            command += ["--is-shuffled", "True"]
        subprocess.run(command, check=True)
        logger.info("Check if dataset was created successfully.")

        created_files_count = sum([1 for _, _, files in os.walk(output_dir) for f in files if f.startswith(file_prefix)])
        logger.info(f"Number of files in the output dataset directory: {created_files_count}")

        if created_files_count != file_count:
            raise Exception("Incorrect number of files.")
        logger.info("Dataset creation successful.")
    except (subprocess.CalledProcessError, Exception) as e:
        logger.error(f"Dataset creation failed: {e}")
        return False
    
    return True


def delete_dataset(dataset_dir: str):
    try:
        if os.path.exists(dataset_dir):
            shutil.rmtree(dataset_dir)
            logger.info(f"Deleted directory: {dataset_dir}")
        else:
            logger.info(f"Directory does not exist: {dataset_dir}")
    except Exception as e:
        logger.error(f"Failed to delete directory: {e}")


def main():
    parser = argparse.ArgumentParser(description="Run benchmarks on a custom dataset.")
    parser.add_argument("--dry-run", action="store_true", help="Print commands and output directory without executing")
    parser.add_argument("--config-dir-path", type=str, help="Path to the config files directory.")
    parser.add_argument("--use-custom-dataset", action="store_true", default=False, 
                        help="Create and delete custom datasets for each case (only with --config-dir-path)")
    args = parser.parse_args()

    if args.config_dir_path:
        # Handle config directory mode - iterate over all config files
        run_with_config_dir(args.config_dir_path, args.dry_run, args.use_custom_dataset)
    else:
        # Handle single config file mode (existing behavior)
        run_with_single_config(args.dry_run)


def run_with_config_dir(config_dir_path: str, dry_run: bool = False, use_custom_dataset: bool = False):
    """Run benchmarks using all config files in the specified directory.
    
    Args:
        config_dir_path: Path to directory containing config files.
        dry_run: If True, print commands without executing.
        use_custom_dataset: If True, create and delete custom datasets for each case.
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

                if use_custom_dataset:
                    create_dataset_args = case['create-dataset-args']
                    create_dataset_args["file-count"] = case["custom-dataset-file-count"]

                    if dry_run:
                        logger.info(f"[DRY-RUN] Would create dataset with args: {create_dataset_args}")
                        run_benchmark(case, config['database'], benchmark_info, dry_run)
                        logger.info(f"[DRY-RUN] Would delete dataset at: {create_dataset_args['save-dir-path']}")
                    else:
                        dataset_created = create_dataset(create_dataset_args)
                        if not dataset_created:
                            logger.error(f"Failed to create dataset for case: {case.get('custom-case-name', case['db-label'])} -- Skipping execution.")
                            teardown_database(config)
                            continue

                        run_benchmark(case, config['database'], benchmark_info, dry_run)
                        delete_dataset(create_dataset_args["save-dir-path"])
                else:
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


def run_with_single_config(dry_run: bool = False):
    """Run benchmarks using the default config.json file."""
    config = load_config("config.json")
    benchmark_info = config["benchmark-info"]
    start_time = time.time()
    start_timeh = time.strftime('%Y-%m-%d %H:%M:%S')
    logger.info(f"Benchmark run start time: {time.strftime('%Y-%m-%d %H:%M:%S')}")

    for case in config['cases']:
        print(f"Running case: {case['db-label']}")
        setup_database(config)
        run_benchmark(case, config['database'], config["benchmark-info"], dry_run)
        teardown_database(config)
    end_timeh = time.strftime('%Y-%m-%d %H:%M:%S')
    output_dir = get_output_dir_path(case, benchmark_info, [], 0, db_config=config['database'], base_dir=True)
    if not dry_run:
        generate_benchmark_metadata(config, start_timeh, end_timeh, output_dir)

    end_time = time.time()
    execution_time = end_time - start_time
    logger.info(f"Benchmark run end time: {time.strftime('%Y-%m-%d %H:%M:%S')}")
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

