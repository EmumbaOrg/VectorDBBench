import os
import pyarrow.parquet as pq
import pyarrow.compute as pc
import pandas as pd
import pyarrow as pa
import argparse
import random
import logging


logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def get_emb_ids_randomly(n: int, range_start: int = 0, range_end: int=500_000) -> list:
    random_ids = []
    random.seed()
    while len(random_ids) < n:
        random_id = random.randint(range_start, range_end)
        if random_id not in random_ids:
            random_ids.append(random_id)
    logger.info(f"Random IDs generated: {random_ids}")
    return random_ids


if __name__ == "__main__":
    """
    This file would only generate a correct test dataset from the original non-shuffled dataset.
    """
    parser = argparse.ArgumentParser(description="Create test dataset parquet file from original dataset.") 
    parser.add_argument("--dataset-path", type=str, help="Path to the directory containing the dataset.")
    parser.add_argument("--save-file-path", type=str, help="Directory path where data will be saved")
    parser.add_argument("--test-dataset-size", type=int, help="Size of the dataset to be created.")        
    args = parser.parse_args()

    logger.info("Parameters received:")
    logger.info(f"Dataset path: {args.dataset_path}")
    logger.info(f"Save file path: {args.save_file_path}")
    logger.info(f"Dataset size: {args.test_dataset_size}")

    save_file_path = (
        args.save_file_path
        if args.save_file_path
        else "test.parquet"
    )

    dataset_size = (
        args.test_dataset_size
        if args.test_dataset_size
        else 10000
    )
    
    files = sorted([f for f in os.listdir(args.dataset_path) if "train" in f])
    file_count = len(files)
    logger.info(f"Number of files starting with 'train': {file_count}")

    row_count = 500_000
    start = 0
    end = row_count

    for file in files:
        logger.info(f"Processing file: {file}, Start: {start}, End: {end}")
        test_query_ids = get_emb_ids_randomly(dataset_size // file_count, start, end)
        start += row_count 
        end += row_count
        file_path = os.path.join(args.dataset_path, file)
        df = pq.read_table(file_path)
        expr = pc.field("id").isin(test_query_ids)
        filtered_df = df.filter(expr)
        logger.info(f"Selected dataset len={len(filtered_df)}")
        logger.info(f"Values: {filtered_df.to_pandas().head()}")
        if 'test_dataset' in locals():
            test_dataset = pa.concat_tables([test_dataset, filtered_df])
        else:
            test_dataset = filtered_df
        logger.info(f"Queries selected from file: {file}")
        del df
    logger.info(f"Created {save_file_path} with {len(test_dataset)} rows.")
    pq.write_table(test_dataset, save_file_path, use_dictionary=False)