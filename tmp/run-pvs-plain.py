import json
import time
from contextlib import redirect_stdout
import random
import subprocess
import psycopg2
from psycopg2 import sql
import os

os.environ["LOG_LEVEL"] = "DEBUG"

def load_config(json_file):
    with open(json_file, 'r') as file:
        config = json.load(file)
    return config

def get_stats(config):
    with open('queries.json', 'r') as file:
        queries = json.load(file)
    try:
        conn = psycopg2.connect(
            dbname=config['db_name'],
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

def pre_warm(config):
    print(f"Running pre warm for database:{config['db_name']}")
    try:
        conn = psycopg2.connect(
                dbname=config['db_name'],
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
        cursor.execute(sql.SQL("SELECT 1 FROM pg_database WHERE datname = %s"), [config['database']['db_name']])
        if not cursor.fetchone():
            cursor.execute(sql.SQL("CREATE DATABASE {}").format(sql.Identifier(config['database']['db_name'])))
        conn.close()

        # Connect to the new database to create the extension
        conn = psycopg2.connect(
            dbname=config['database']['db_name'],
            user=config['database']['username'],
            password=config['database']['password'],
            host=config['database']['host']
        )
        cursor = conn.cursor()
        cursor.execute("CREATE EXTENSION IF NOT EXISTS vectorscale CASCADE;")
        cursor.execute("CREATE EXTENSION IF NOT EXISTS pg_buffercache;")
        cursor.execute("CREATE EXTENSION IF NOT EXISTS pg_prewarm;")
        conn.commit()
        conn.close()
    except Exception as e:
        print(f"Setup failed: {e}")

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
            dbname=config['db_name'],
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


def run_benchmark(case, db_config):
    base_command = [
        "vectordbbench", "pgvectorscale",
        "--user-name", db_config['username'],
        "--password", db_config['password'],
        "--host", db_config['host'],
        "--db-name", db_config['db_name']
    ]

    # Handle initial flags (no skip for the first ef_search)
    if case.get("drop_old", True):
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

    base_command.extend([
        "--case-type", case["case-type"],
        "--maintenance-work-mem", case["maintenance-work-mem"],
        "--max-parallel-workers", str(case["max-parallel-workers"]),
        "--k", str(case["k"]),
        "--num-concurrency", case["num-concurrency"],
        "--concurrency-duration", str(case["concurrency-duration"])
    ])

    # Add pgvectorscale-specific parameters (excluding query-time parameters here for iteration)
    base_command.extend([
        "--storage-layout", case["storage-layout"],
        "--num-neighbors", str(case["num-neighbors"]),
        "--search-list-size", str(case["search-list-size"]),
        "--max-alpha", str(case["max-alpha"]),
        "--num-dimensions", str(case["num-dimensions"])
    ])

    run_count = case.get("run_count", 1)  # Default to 1 if not specified

    for run in range(run_count):
        print(f"Starting run {run + 1} of {run_count} for case: {case['db-label']}")
        for i, query_search_list_size in enumerate(case["query-search-list-size"]):
            command = base_command + [
                        "--query-search-list-size", str(query_search_list_size),
                    ]

            if i > 0 or run > 0:
                # Remove conflicting --drop-old and --load flags
                command = [arg for arg in command if arg not in ["--drop-old", "--load"]]
                # Add skip flags if they are not already in the command
                if "--skip-drop-old" not in command:
                    command.append("--skip-drop-old")
                if "--skip-load" not in command:
                    command.append("--skip-load")

            try:
                random_number = random.randint(1, 100000)
                print(f"Running command: {' '.join(command)}")
                output_dir = (
                        f"results/pgvectorscale/{case['db-label']}/{db_config['provider']}/"
                        f"{db_config['instance_type']}-"
                        f"{case['storage-layout']}-"
                        f"{case['num-neighbors']}-"
                        f"{case['search-list-size']}-"
                        f"{case['max-alpha']}-"
                        f"{query_search_list_size}-"
                        f"{case['case-type']}-{run}-{random_number}"
                        )
                os.environ["RESULTS_LOCAL_DIR"] = output_dir

                os.makedirs(output_dir, exist_ok=True)

                with open(f"{output_dir}/log.txt", 'w') as f:
                    with redirect_stdout(f):
                        print(f"DB Instance Type: {db_config['instance_type']}")
                        print(f"DB Instance Provider: {db_config['provider']}")
                        print(f"DB enable_seqscan: {db_config['enable_seqscan']}")
                        for key, value in case.items():
                            if key == "query-search-list-size":
                                print(f"{key}: {query_search_list_size}")
                            print(f"{key}: {value}")
                        print("Current PostgreSQL configurations:")
                        current_configs = query_configurations(db_config)
                        for key, value in current_configs.items():
                            print(f"{key}: {value}")
                        get_stats(db_config)
                        f.flush()
                        pre_warm(db_config)
                        print(f"Running command: {' '.join(command)}")
                        f.flush()

                    print("***********START***********")
                    start_time = time.time()
                    # Capture both stdout and stderr and write them to the log file
                    subprocess.run(command, check=True, stdout=f, stderr=f)
                    end_time = time.time()
                    execution_time = end_time - start_time
                    print(f"total_duration={execution_time}")
                    print("***********END***********")
                    with redirect_stdout(f):
                        get_stats(db_config)
                        f.flush()
                    f.flush()
            except subprocess.CalledProcessError as e:
                print(f"Benchmark failed: {e}")
            print("Sleeping for 30 sec")
            time.sleep(60)

def main():
    config = load_config("config.json")
    start_time = time.time()
    for case in config['cases']:
        print(f"Running case: {case['db-label']}")
        setup_database(config)

        run_benchmark(case, config['database'])
        teardown_database(config)
    end_time = time.time()
    execution_time = end_time - start_time
    print(f"COMPLETED ALL EXECUTIONS. total_duration={execution_time}")

if __name__ == "__main__":
    main()

