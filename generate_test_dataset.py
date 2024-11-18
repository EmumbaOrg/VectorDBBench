import pyarrow as pa
import pyarrow.parquet as pq
import pandas as pd
import numpy as np
import glob
import gc
import argparse
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Parse command line arguments
parser = argparse.ArgumentParser(description='Generate test dataset from Parquet files.')
parser.add_argument('--folder-path', type=str, required=True, help='Path to the folder containing the train files')
parser.add_argument('--file-pattern', type=str, required=False, help='Pattern to match the train files')
parser.add_argument('--queries-per-file', type=int, required=False, help='Number of queries to sample per file')
parser.add_argument('--output-file', type=str, required=False, help='Output Parquet file name')

args = parser.parse_args()

folder_path = args.folder_path
file_pattern = (
    args.file_pattern
    if args.file_pattern
    else "train-*-of-10.parquet"
)
queries_per_file = (
    args.queries_per_file
    if args.queries_per_file
    else 1000
)
output_file = (
    args.output_file
    if args.output_file
    else 'test-10000.parquet'
)

logging.info(f"Folder path: {folder_path}")
logging.info(f"File pattern: {file_pattern}")
logging.info(f"Queries per file: {queries_per_file}")
logging.info(f"Output file: {output_file}")

schema = pa.schema([
    pa.field('id', pa.int64()),
    pa.field('emb', pa.list_(pa.float64()))  # emb as a list of double precision floats
])

# Open Parquet writer with the specified schema
with pq.ParquetWriter(output_file, schema) as writer:
    # Track the current ID incrementally
    current_id = 0

    # Loop through each file and sample specified queries
    for file_path in glob.glob(folder_path + file_pattern):
        logging.info(f"Processing file: {file_path}")

        # Load and sample data
        train_table = pq.read_table(file_path, columns=['id', 'emb'])
        train_df = train_table.to_pandas()
        sampled_df = train_df.sample(n=queries_per_file).reset_index(drop=True)

        # Reassign IDs starting from the current count
        sampled_df['id'] = np.arange(current_id, current_id + queries_per_file)
        current_id += queries_per_file

        # Convert the DataFrame to a PyArrow table with the specified schema
        sampled_table = pa.Table.from_pandas(sampled_df, schema=schema)

        # Write the sampled data to the output file
        writer.write_table(sampled_table)

        # Clean up to free memory
        del train_table, train_df, sampled_df, sampled_table
        gc.collect()

        logging.info(f"Finished processing file: {file_path}")

logging.info(f"{output_file} has been created with {queries_per_file} randomly sampled embeddings per file.")