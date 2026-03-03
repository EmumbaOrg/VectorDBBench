import json
from typing import Tuple, List
import psycopg2
from psycopg2 import sql


def insert_data(data: List[dict], reset_records: bool=False, csp_db: bool=False):
    print("Connecting to the database...")
    db_cofigurations = get_db_config()
    db_config = (
        db_cofigurations["csp_db"]
        if csp_db
        else db_cofigurations["local"]
    )
    conn = psycopg2.connect(**db_config)
    print("Connected to the database")
    try:
        cur = conn.cursor()
        if reset_records:
            cur.execute("DELETE FROM benchmark_results")
            conn.commit()
            print("benchmark_results Table Deleted")

        for count, record in enumerate(data):
            print(f"Inserting record into the results table: {count+1}")
            insert_fields, insert_values = build_query_params(record)
            insert_query = sql.SQL(
                f"""INSERT INTO benchmark_results ({",".join(insert_fields)}) VALUES ({', '.join(['%s' for _ in insert_values])})"""
            )
            cur.execute(insert_query, insert_values)
            conn.commit()
    except Exception as e:
        print(f"Error: {e}")
    finally:
        print("Inserting data into the results table finished")
        cur.close()
        conn.close()

def get_db_config():
    with open("script/db_configs.json") as f:
        all_db_configs = json.load(f)
    return all_db_configs

def build_query_params(record: dict) -> Tuple[str, str]:
    insert_fields = []
    insert_values = []
    for key, val in record.items():
        insert_fields.append(key)
        if isinstance(val, dict):
            insert_values.append(json.dumps(val))
        else:
            insert_values.append(val)
    return insert_fields, insert_values
