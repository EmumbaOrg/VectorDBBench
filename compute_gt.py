import argparse
import numpy as np
import pandas as pd
import pyarrow as pa
import psycopg
import psycopg.sql as sql
import pyarrow.parquet as pq
from pgvector.psycopg import register_vector


def query_database(query, emb, k, cursor):
    result = cursor.execute(query, (emb, k), prepare=True, binary=True)
    return [int(i[0]) for i in result.fetchall()]

def write_parquet_file(data, file_path):
    df = pd.DataFrame(data, columns=["id", "neighbors_id"])
    table = pa.Table.from_pandas(df)
    pq.write_table(table, file_path, use_dictionary=False)

def main():
    parser = argparse.ArgumentParser(description="Create subsets of Parquet files using Dask.")
    parser.add_argument("--test-file-path", type=str, help="Path of the parquet test file.")
    parser.add_argument("--gt-file-path", type=str, help="Parquet file path where ground truth will be saved.")
    parser.add_argument("--table-name", type=str, help="Vector table name")
    parser.add_argument("--k", type=str, help="K nearest neighbors")
    parser.add_argument("--db-name", type=str, help="Database name")
    parser.add_argument("--db-user", type=str, help="Database user")
    parser.add_argument("--db-pass", type=str, help="Database password")
    parser.add_argument("--host", type=str, help="Database host")
    parser.add_argument("--port", type=str, help="Database port")
    args = parser.parse_args()

    '''
    vectordbbench pgvectorhnsw --drop-old --load --skip-search-serial --skip-search-concurrent --case-type PerformanceCustomDataset --user-name postgres  --password admin123 --host 172.17.0.2 --db-name postgres --maintenance-work-mem 4GB --max-parallel-workers 3 --ef-search 100 --ef-construction 64 --m 16 --k 10 --num-concurrency 1,5,10,15,20,25,30 --custom-case-name "Computing GT for 500k openai" --custom-dataset-name custom-openai --custom-dataset-dir subset_500k --custom-dataset-size 500000 --custom-dataset-dim 1536 --custom-dataset-file-count 10 --custom-dataset-use-shuffled
    '''

    df = pd.read_parquet(args.test_file_path)
    try:
        connection = psycopg.connect(
            dbname=args.db_name,
            user=args.db_user,
            password=args.db_pass,
            host=args.host,
            port=args.port,
        )
        register_vector(connection)
        print("Connection established.")

        results = []
        count = 0
        for _, row in df.iterrows():
            q = np.asarray(row["emb"])
            query = sql.Composed(
                    [
                        sql.SQL("SELECT id FROM public.{} ORDER BY embedding <=> ").format(
                            sql.Identifier(args.table_name)
                        ),
                        sql.SQL(" %s::vector LIMIT %s::int"),
                    ]
                )
            result = (row["id"], np.asarray(query_database(query, q, args.k, connection)))
            results.append(result)
            count += 1
            if count%10 == 0:
                print(f"GT computed for {count} rows.")
        connection.close()

        write_parquet_file(results, args.gt_file_path)
        print("Ground truth calculated and saved.")
    except:
        print("Connection failed.")
        connection.close()
    finally:
        connection.close()

if __name__ == "__main__":
    main()
