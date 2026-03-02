import argparse
import json
import psycopg2


parser = argparse.ArgumentParser(description="Drop existing table and create a new one")
parser.add_argument("--drop", action="store_true", help="Drop table")
parser.add_argument("--csp-db", action="store_true", help="Drop table")
args = parser.parse_args()


print("Connecting to the database...")
with open("script/db_configs.json") as f:
    all_db_configs = json.load(f)
db_configs = all_db_configs["local"]
if args.csp_db:
    db_configs = all_db_configs["csp_db"]

conn = psycopg2.connect(**db_configs)
print("Connected to the database")

try:
    cur = conn.cursor()
    if args.drop:
        cur.execute("DROP TABLE benchmark_results")
        conn.commit()
        print("Table Dropped")
    cur.execute(
        """
        CREATE TABLE IF NOT EXISTS benchmark_results (
            id SERIAL PRIMARY KEY,
            run_id VARCHAR(64) DEFAULT '',
            csp VARCHAR(32) DEFAULT '',
            load_duration FLOAT DEFAULT NULL,
            recall FLOAT DEFAULT NULL,
            qps FLOAT DEFAULT NULL,
            qps_per_dollar FLOAT DEFAULT NULL,
            index_build_time FLOAT DEFAULT NULL,
            instance_type VARCHAR(64) DEFAULT '',
            index_params JSON DEFAULT '{}',
            search_params JSON DEFAULT '{}',
            config_label TEXT DEFAULT '',
            index_type VARCHAR(64) DEFAULT '',
            db_case_config JSON DEFAULT '{}',
            raw_data JSON DEFAULT '{}',
            metric_type VARCHAR(64) DEFAULT '',
            logs TEXT DEFAULT '',
            enable_seqscan VARCHAR(32) DEFAULT '',
            db_label VARCHAR(64) DEFAULT '',
            drop_old BOOLEAN DEFAULT FALSE,
            load BOOLEAN DEFAULT FALSE,
            search_serial BOOLEAN DEFAULT FALSE,
            search_concurrent BOOLEAN DEFAULT FALSE,
            conc_latency_p99_list FLOAT[],
            conc_num_list FLOAT[],
            conc_qps_list FLOAT[],
            case_type VARCHAR(64) DEFAULT '',
            maintenance_work_mem VARCHAR(32) DEFAULT '',
            max_parallel_workers INTEGER DEFAULT 0,
            num_concurrency FLOAT[],
            concurrency_duration INTEGER DEFAULT 0,
            run_count INTEGER DEFAULT 0,
            checkpoint_timeout VARCHAR(64) DEFAULT '',
            effective_cache_size VARCHAR(64) DEFAULT '',
            jit VARCHAR(255) DEFAULT '',
            max_parallel_maintenance_workers INTEGER DEFAULT 0,
            max_parallel_workers_per_gather INTEGER DEFAULT 0,
            max_wal_size VARCHAR(32) DEFAULT '',
            max_worker_processes INTEGER DEFAULT 0,
            shared_buffers VARCHAR(32) DEFAULT '',
            wal_compression VARCHAR(32) DEFAULT '',
            work_mem VARCHAR(32) DEFAULT '',
            create_index_before_load BOOLEAN DEFAULT FALSE,
            create_index_after_load BOOLEAN DEFAULT FALSE,
            index_size VARCHAR(32) DEFAULT '',
            k INTEGER DEFAULT NULL,
            max_load_count INTEGER DEFAULT NULL,
            ndcg FLOAT DEFAULT NULL,
            serial_latency_p99 FLOAT DEFAULT NULL,
            table_size VARCHAR(32) DEFAULT '',
            vector_extension VARCHAR(32) DEFAULT ''
        )
    """
    )
    conn.commit()
    print("Created the results table")
except Exception as e:
    print(e)
finally:
    cur.close()
    conn.close()

print("Database setup complete")
