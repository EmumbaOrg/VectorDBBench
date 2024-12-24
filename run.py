import argparse
import json
import time
import subprocess
from typing import List, Optional
import psycopg2
import os
import logging
from psycopg2 import sql
from contextlib import redirect_stdout
from itertools import product

logger = logging.getLogger(__file__)
logger.setLevel(logging.DEBUG)
handler = logging.StreamHandler()
handler.setLevel(logging.DEBUG)
formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)

os.environ["LOG_LEVEL"] = "DEBUG"


def load_config(json_file):
    with open(json_file, 'r') as file:
        config = json.load(file)
    return config

def setup_database(config):
    try:
        conn = psycopg2.connect(
            dbname='postgres',
            user=config['database']['username'],
            password=config['database']['password'],
            host=config['database']['host']
        )
        conn.autocommit = True
        cursor = conn.cursor()
        # Create the database if it doesn't exist
        cursor.execute(sql.SQL("SELECT 1 FROM pg_database WHERE datname = %s"), [config['database']['db-name']])
        if not cursor.fetchone():
            cursor.execute(sql.SQL("CREATE DATABASE {}").format(sql.Identifier(config['database']['db-name'])))
        conn.close()

        # Connect to the new database to create the extension
        conn = psycopg2.connect(
            dbname=config['database']['db-name'],
            user=config['database']['username'],
            password=config['database']['password'],
            host=config['database']['host']
        )
        cursor = conn.cursor()
        cursor.execute("CREATE EXTENSION IF NOT EXISTS pg_buffercache;")
        cursor.execute("CREATE EXTENSION IF NOT EXISTS pg_prewarm;")
        cursor.execute("CREATE EXTENSION IF NOT EXISTS vector;")
        try:
            cursor.execute("CREATE EXTENSION IF NOT EXISTS pg_diskann;")
        except Exception as e:
            logger.error(f"Installing pgdiskann extension failed: {e}")

        try:
            cursor.execute("CREATE EXTENSION IF NOT EXISTS vectorscale;")
        except Exception as e:
            logger.error(f"Installing vectorscale extension failed: {e}")

        conn.commit()
        conn.close()
    except Exception as e:
        print(f"Setup failed: {e}")

def get_stats(config):
    with open('queries.json', 'r') as file:
        queries = json.load(file)
    try:
        conn = psycopg2.connect(
            dbname=config['db-name'],
            user=config['username'],
            password=config['password'],
            host=config['host']
        )
        cur = conn.cursor()
        for item in queries:
            query = item['query']
            description = item['description']
            print(f"\nRunning query: {description}")
            try:
                cur.execute(query)
                rows = cur.fetchall()
                headers = [desc[0] for desc in cur.description]
                print(f"{' | '.join(headers)}")
                for row in rows:
                    print(f"{' | '.join(map(str, row))}")
            except Exception as e:
                print(f"Failed to run query: {e}")
        conn.close()
    except Exception as e:
        print(f"Setup failed: {e}")
    finally:
        conn.close()

def run_pre_warm(config):
    print(f"Running pre warm for database:{config['db-name']}")
    try:
        conn = psycopg2.connect(
                dbname=config['db-name'],
                user=config['username'],
                password=config['password'],
                host=config['host'],
        )
        cursor = conn.cursor()
        cursor.execute("SELECT pg_prewarm('public.pgvector_index') as block_loaded")
        conn.commit()

        result = cursor.fetchone()
        print(f"Pre-warm blocks loaded: {result[0]}")
        conn.close()
    except Exception as e:
        print(f"Failed to pre-warm the database: {e}")

def teardown_database(config):
    # Optionally drop the database after the test
    pass

def query_configurations(config):
    # List of configuration parameters to query
    config_queries = [
        "SHOW checkpoint_timeout;",
        "SHOW effective_cache_size;",
        "SHOW jit;",
        "SHOW maintenance_work_mem;",
        "SHOW max_parallel_maintenance_workers;",
        "SHOW max_parallel_workers;",
        "SHOW max_parallel_workers_per_gather;",
        "SHOW max_wal_size;",
        "SHOW max_worker_processes;",
        "SHOW shared_buffers;",
        "SHOW wal_compression;",
        "SHOW work_mem;"
    ]

    try:
        conn = psycopg2.connect(
            dbname=config['db-name'],
            user=config['username'],
            password=config['password'],
            host=config['host']
        )
        cursor = conn.cursor()
        results = []

        # Execute each query and collect the result
        for query in config_queries:
            cursor.execute(query)
            result = cursor.fetchone()
            results.append(result[0] if result else None)

        # Print the raw output to debug
        print("Raw query results:", results)

        config_dict = {
            "checkpoint_timeout": results[0],
            "effective_cache_size": results[1],
            "jit": results[2],
            "maintenance_work_mem": results[3],
            "max_parallel_maintenance_workers": results[4],
            "max_parallel_workers": results[5],
            "max_parallel_workers_per_gather": results[6],
            "max_wal_size": results[7],
            "max_worker_processes": results[8],
            "shared_buffers": results[9],
            "wal_compression": results[10],
            "work_mem": results[11]
        }

        conn.close()
        return config_dict
    except Exception as e:
        print(f"Failed to query configurations: {e}")
        return {}

def get_base_command(case: dict, db_config: dict) -> list:
    base_command = [
        "vectordbbench", case["vdb-command"],
        "--user-name", db_config["username"],
        "--password", db_config["password"],
        "--host", db_config["host"],
        "--db-name", db_config["db-name"],
        "--case-type", case["case-type"],
        "--num-concurrency", case["num-concurrency"],
        "--concurrency-duration", str(case["concurrency-duration"])
    ]

    # Handle initial flags (no skip for the first ef_search)
    if case.get("drop-old", True):
        base_command.append("--drop-old")
    else:
        base_command.append("--skip-drop-old")

    if case.get("load", True):
        base_command.append("--load")
    else:
        base_command.append("--skip-load")

    if case.get("search-serial", True):
        base_command.append("--search-serial")
    else:
        base_command.append("--skip-search-serial")

    if case.get("search-concurrent", True):
        base_command.append("--search-concurrent")
    else:
        base_command.append("--skip-search-concurrent")
    
    for key, value in case["index-params"].items():
        base_command.extend([f"--{key}", str(value)])

    return base_command

def handle_drop_old_load_flags(command) -> list[str]:
    """If --drop-old or --load flags are present, remove them and add skip flags"""
    command = [arg for arg in command if arg not in ["--drop-old", "--load"]]
    if "--skip-drop-old" not in command:
        command.append("--skip-drop-old")
    if "--skip-load" not in command:
        command.append("--skip-load")
    return command

def get_extension_version(db_config: dict):
    try:
        conn = psycopg2.connect(
            dbname=db_config['db-name'],
            user=db_config['username'],
            password=db_config['password'],
            host=db_config['host']
        )
        cursor = conn.cursor()
        cursor.execute("SELECT extname, extversion FROM pg_extension WHERE extname LIKE '%vec%' OR extname LIKE '%ann%' OR extname = 'scann';")
        extensions = cursor.fetchall()
        conn.close()
        extensions = {ext[0]: ext[1] for ext in extensions}
        return extensions
    except Exception as e:
        print(f"Failed to get extension versions: {e}")
        return {}

def get_postgres_version(db_config: dict):
    try:
        conn = psycopg2.connect(
            dbname=db_config['db-name'],
            user=db_config['username'],
            password=db_config['password'],
            host=db_config['host']
        )
        cursor = conn.cursor()
        cursor.execute("SELECT version();")
        pgversion = cursor.fetchone()
        conn.close()
        return pgversion[0]
    except Exception as e:
        print(f"Failed to get extension versions: {e}")
        return ""
    
def get_output_dir_path(
    case: dict,
    benchmark_info: dict,
    search_params: Optional[List[str | int]],
    run: Optional[int],
    db_config: dict,
    base_dir: bool = False,
) -> str:
    ext_version = get_extension_version(db_config)
    output_dir = f"results/{case['vector-ext']}-{ext_version[case['vector-ext']]}/{case['index-type']}/{case['db-label']}/{benchmark_info['provider']}/{benchmark_info['instance-service']}/{benchmark_info['instance-service']}/{case['case-type']}/"
    if base_dir:
        return output_dir

    for key, value in case["index-params"].items():
        if key not in ["maintenance-work-mem", "max-parallel-workers"]:
            output_dir += f"{value}-"
    for val in search_params:
        if val.isdigit():
            output_dir += f"{val}-"
    output_dir += f"{run}-{int(time.time())}"
    return output_dir

def print_configuration(
    case: dict,
    benchmark_info: dict,
    db_config: dict,
    command: list,
    output_file,
):
    with redirect_stdout(output_file):
        logger.info("Benchmark Information:")
        for key, value in benchmark_info.items():
            logger.info(f"{key}: {value}")
        output_file.flush()
        
        logger.info("Benchmark Test Run Information:")
        for key, value in case.items():
            logger.info(f"{key}: {value}")
        output_file.flush()
        
        logger.info(f"Postgres Database Configuration")
        current_configs = query_configurations(db_config)
        for key, value in current_configs.items():
            logger.info(f"{key}: {value}")
        output_file.flush()
        
        logger.info(f"Get Buffer Hit Ratio Stats")
        get_stats(db_config)
        output_file.flush()

        logger.info(f"Running command: {' '.join(command)}")
        output_file.flush()

def generate_combinations(config_dict: dict) -> list:
    keys = []
    values = []
    for key, value in config_dict.items():
        keys.append(f"--{key}")
        if isinstance(value, list):
            values.append(value)
        else:
            values.append([value])

    combinations = []
    for combo in product(*values):
        combination = []
        for k, v in zip(keys, combo):
            combination.append((k, str(v)))
        combinations.append([item for pair in combination for item in pair])
    
    logger.info(f"Total combinations generated: {len(combinations)}")
    return combinations

def generate_benchmark_metadata(
    metadata: dict,
    start_time: str,
    end_time: str,
    output_dir: str,
):
    metadata["benchmark-info"]["extension-versions"] = get_extension_version(metadata['database'])
    metadata["benchmark-info"]["postgres_version"] = get_postgres_version(metadata['database'])
    metadata["benchmark-info"]["start_time"] = start_time
    metadata["benchmark-info"]["end_time"] = end_time
    del metadata["database"]

    output_filename = f"{output_dir}benchmark_metadata.json"
    with open(output_filename, "w") as f:
        json.dump(metadata, f, indent=4)
        logger.info(f"Benchmark metadata saved to {output_filename}")

def run_benchmark(case, db_config, benchmark_info, dry_run=False):
    base_command = get_base_command(case, db_config)
    run_count = case.get("run-count", 1)  # Default to 1 if not specified
    for run in range(run_count):
        print(f"Starting run {run + 1} of {run_count} for case: {case['db-label']}")
        for i, search_params in enumerate(generate_combinations(case["search-params"])):
            command = base_command + search_params
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
                        run_pre_warm(db_config)
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
                except subprocess.CalledProcessError as e:
                    logger.error(f"Benchmark Failed: {e}")
                logger.info("Sleeping for 1 min")
                time.sleep(60)

def parse_argument():
    parser = argparse.ArgumentParser(description="Run HNSW benchmark")
    parser.add_argument("--dry-run", action="store_true", help="Print commands and output directory without executing")
    return parser.parse_args()


def main():
    args = parse_argument()
    config = load_config("config.json")
    start_time = time.time()
    start_timeh = time.strftime('%Y-%m-%d %H:%M:%S')
    benchmark_info = config["benchmark-info"]
    logger.info(f"Benchmark run start time: {time.strftime('%Y-%m-%d %H:%M:%S')}")
    for case in config['cases']:
        print(f"Running case: {case['db-label']}")
        setup_database(config)
        run_benchmark(case, config['database'], config["benchmark-info"], args.dry_run)
        teardown_database(config)
    end_timeh = time.strftime('%Y-%m-%d %H:%M:%S')

    output_dir = get_output_dir_path(case, benchmark_info, [], 0, db_config=config['database'], base_dir=True)
    if not args.dry_run:
        generate_benchmark_metadata(config, start_timeh, end_timeh, output_dir)

    end_time = time.time()
    execution_time = end_time - start_time
    logger.info(f"Benchmark run end time: {time.strftime('%Y-%m-%d %H:%M:%S')}")
    logger.info(f"COMPLETED ALL EXECUTIONS. total_duration={execution_time}")

if __name__ == "__main__":
    main()

