import os
import shutil
import argparse
import logging

# Set up logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

def get_file_name(file_name: str, file_prefix: str, files_count: int) -> str:
    if files_count == 1:
        return file_prefix + ".parquet"
    file_name = file_name.split("of-")[0]
    return file_name + "of-" + str(files_count).zfill(2) + ".parquet"

def create_dataset(base_dir, save_dir_path, subset_prefix, file_prefix, file_count, row_count=500_000):
    logger.info(f"Starting dataset creation with {file_count} files.")

    # Sort the files and pick only the first 'file_count' files
    files = sorted([f for f in os.listdir(base_dir) if f.startswith(file_prefix)])[:file_count]
    num_files = len(files)

    if num_files == 0:
        logger.warning("No files found with the specified prefix.")
        return

    logger.info(f"Found {num_files} files. Creating dataset...")

    # Create the directory for the dataset
    subset_dir = os.path.join(save_dir_path, f"{subset_prefix}_{file_count * row_count // 1000}k")
    os.makedirs(subset_dir, exist_ok=True)
    logger.info(f"Created directory for the dataset: {subset_dir}")

    # Copy the first 'file_count' files into the subset directory
    for file in files:
        src_file = os.path.join(base_dir, file)
        dst_file = os.path.join(subset_dir, get_file_name(file, file_prefix, file_count))
        shutil.copy(src_file, dst_file)
        logger.info(f"Copied {file} to {dst_file}")
    
    # Also copy the test.parquet file
    #src_test_file = os.path.join(base_dir, "test.parquet")
    src_test_file = "custom-data/test.parquet"
    dst_test_file = os.path.join(subset_dir, "test.parquet")
    shutil.copy(src_test_file, dst_test_file)
    logger.info(f"Copied test.parquet to {subset_dir}")

    src_test_file = os.path.join(base_dir, "neighbors.parquet")
    dst_test_file = os.path.join(subset_dir, "neighbors.parquet")
    shutil.copy(src_test_file, dst_test_file)
    logger.info(f"Copied neighbors.parquet to {subset_dir}")

    logger.info(f"Dataset creation completed. {file_count} files have been copied to {subset_dir}.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Create a dataset with a specified number of Parquet files.")
    parser.add_argument("--directory", type=str, required=True, help="Path to the directory containing Parquet files.")
    parser.add_argument("--save-dir-path", type=str, required=True, help="Directory path where the dataset will be saved.")
    parser.add_argument("--dataset-name-prefix", type=str, help="Name prefix for the dataset folder.")
    parser.add_argument("--is-shuffled", type=bool, help="Whether the files are shuffled or not.")
    parser.add_argument("--file-count", type=int, required=True, help="Number of Parquet files to include in the dataset.")
    args = parser.parse_args()

    file_prefix = (
        "shuffle_train"
        if args.is_shuffled
        else "train"
    )
    subset_prefix = (
        args.dataset_name_prefix
        if args.dataset_name_prefix
        else "openai"
    )
    save_dir_path = (
        args.save_dir_path
        if args.save_dir_path
        else args.directory
    )

    if os.path.exists(save_dir_path) and os.listdir(save_dir_path):
        shutil.rmtree(save_dir_path)
        logger.info(f"Deleted existing directory: {save_dir_path}")
    
    # Log the input parameters
    logger.info(f"Parameters received: directory={args.directory}, save_dir_path={args.save_dir_path}, file_count={args.file_count}, dataset_name_prefix={subset_prefix}, is_shuffled={args.is_shuffled}")

    # Create the dataset with the specified file_count
    create_dataset(args.directory, save_dir_path, subset_prefix, file_prefix, args.file_count)
    logger.info(f'Finished creating a dataset with {args.file_count} Parquet files.')
