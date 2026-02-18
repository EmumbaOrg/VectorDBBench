import argparse
import json
import time
from contextlib import redirect_stdout
import subprocess
import psycopg
from psycopg import sql
import os

os.environ["LOG_LEVEL"] = "DEBUG"


def load_config(json_file):
    with open(json_file, 'r') as file:
        config = json.load(file)
    return config


def setup_database(config):
    try:
        conn = psycopg.connect(
            dbname='postgres',
            user=config['database']['username'],
            password=config['database']['password'],
            host=config['database']['host']
        )
        conn.autocommit = True
        cursor = conn.cursor()
        db_name = config['database']['db-name']
        cursor.execute(
            sql.SQL("SELECT 1 FROM pg_database WHERE datname = %s"), [db_name]
        )
        if not cursor.fetchone():
            cursor.execute(
                sql.SQL("CREATE DATABASE {}").format(sql.Identifier(db_name))
            )
            print(f"Created database: {db_name}")
        else:
            print(f"Database already exists: {db_name}")
        conn.close()

        conn = psycopg.connect(
            dbname=db_name,
            user=config['database']['username'],
            password=config['database']['password'],
            host=config['database']['host']
        )
        cursor = conn.cursor()
        for ext in ["vector", "pg_diskann", "pg_buffercache"]:
            try:
                cursor.execute(f"CREATE EXTENSION IF NOT EXISTS {ext} CASCADE;")
                conn.commit()
                print(f"Extension installed: {ext}")
            except Exception as e:
                print(f"Failed to install extension {ext}: {e}")
        conn.close()
    except Exception as e:
        print(f"Setup failed: {e}")


def query_configurations(config):
    config_queries = [
        "SHOW checkpoint_timeout;", "SHOW effective_cache_size;",
        "SHOW jit;", "SHOW maintenance_work_mem;",
        "SHOW max_parallel_maintenance_workers;", "SHOW max_parallel_workers;",
        "SHOW max_parallel_workers_per_gather;", "SHOW max_wal_size;",
        "SHOW max_worker_processes;", "SHOW shared_buffers;",
        "SHOW wal_compression;", "SHOW work_mem;"
    ]
    try:
        conn = psycopg.connect(
            dbname=config['db-name'],
            user=config['username'],
            password=config['password'],
            host=config['host']
        )
        cursor = conn.cursor()
        results = []
        for query in config_queries:
            cursor.execute(query)
            result = cursor.fetchone()
            results.append(result[0] if result else None)
        conn.close()
        return {
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
    except Exception as e:
        print(f"Failed to query configurations: {e}")
        return {}


def get_base_command(case, db_config):
    base_command = [
        "vectordbbench", case["vdb-command"],
        "--user-name", db_config["username"],
        "--password", db_config["password"],
        "--host", db_config["host"],
        "--db-name", db_config["db-name"],
        "--case-type", case["case-type"],
        "--k", str(case["k"]),
        "--num-concurrency", case["num-concurrency"],
        "--concurrency-duration", str(case["concurrency-duration"]),
    ]

    # Always load, never search (index build only)
    base_command.append("--drop-old")
    base_command.append("--load")
    base_command.append("--skip-search-serial")
    base_command.append("--skip-search-concurrent")

    # Add index params
    for key, value in case["index-params"].items():
        base_command.extend([f"--{key}", str(value)])

    return base_command


def run_index_build(case, db_config, output_dir):
    command = get_base_command(case, db_config)

    os.makedirs(output_dir, exist_ok=True)
    print(f"Running command: {' '.join(command)}")
    os.environ["RESULTS_LOCAL_DIR"] = output_dir

    with open(f"{output_dir}/log.txt", 'w') as f:
        with redirect_stdout(f):
            print(f"Index Build Config:")
            print(f"  DB Name: {db_config['db-name']}")
            print(f"  Case: {case['db-label']}")
            print(f"  Index Type: {case['index-type']}")
            print(f"  Index Params: {case['index-params']}")
            print(f"\nPostgreSQL Configuration:")
            current_configs = query_configurations(db_config)
            for key, value in current_configs.items():
                print(f"  {key}: {value}")
            print(f"\nRunning command: {' '.join(command)}")
            f.flush()

        try:
            print("***********START INDEX BUILD***********")
            start_time = time.time()
            subprocess.run(command, check=True, stdout=f, stderr=f)
            end_time = time.time()
            print(f"Index build duration: {end_time - start_time:.2f}s")
            print("***********END INDEX BUILD***********")
        except subprocess.CalledProcessError as e:
            print(f"Index build failed: {e}")
        f.flush()


def main():
    parser = argparse.ArgumentParser(description="Build indexes from config directory.")
    parser.add_argument(
        "--config-dir-path",
        type=str,
        default="./index-build-configs",  
        help="Path to directory containing index build config JSON files (default: ./index-build-configs)"
    )
    args = parser.parse_args()

    # Check if directory exists
    if not os.path.exists(args.config_dir_path):
        print(f"ERROR: Config directory does not exist: {args.config_dir_path}")
        print(f"Please create the directory and add config JSON files.")
        return

    # Walk through all config files in directory
    config_count = 0
    for dir_path, _, file_names in os.walk(args.config_dir_path):
        for file_name in sorted(file_names):          

            if not file_name.endswith('.json'):        # skip non-JSON files
                continue

            config_count += 1
            config_path = os.path.join(dir_path, file_name)
            print(f"\n{'='*60}")
            print(f"Loading config: {config_path}")
            print(f"{'='*60}")

            config = load_config(config_path)
            start_time = time.time()

            for case in config['cases']:
                print(f"\nRunning case: {case['db-label']}")
                print(f"Database: {config['database']['db-name']}")

                # Setup database (creates DB + installs extensions)
                setup_database(config)

                # Build output directory path
                output_dir = (
                    f"results/{case['vector-ext']}/{case['index-type']}/"
                    f"{case['db-label']}/{config['benchmark-info']['provider']}/"
                    f"{config['benchmark-info']['instance-service']}/"
                    f"{case['case-type']}"
                )

                # Run index build only (no search)
                run_index_build(case, config['database'], output_dir)

            end_time = time.time()
            print(f"\nCompleted config {file_name} in {end_time - start_time:.2f}s")

    if config_count == 0:
        print(f"\nWARNING: No JSON config files found in {args.config_dir_path}")
        print(f"Please add config files to this directory.")
    else:
        print(f"\n{'='*60}")
        print(f"COMPLETED ALL INDEX BUILDS: {config_count} configs processed")
        print(f"{'='*60}")


if __name__ == "__main__":
    main()