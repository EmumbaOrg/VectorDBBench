import os
import shutil
import argparse


def get_file_name(file_name: str, file_prefix: str, num_files: int) -> str:
    if num_files == 1:
        return file_prefix + ".parquet"
    file_name = file_name.split("of-")[0]
    return file_name + "of-" + str(num_files).zfill(2) + ".parquet"

def create_subsets(base_dir, file_prefix, subset_prefix, step_size):
    files = sorted([f for f in os.listdir(base_dir) if f.startswith(file_prefix)])
    num_files = len(files)
    
    for i in range(1, num_files + 1):
        subset_dir = os.path.join(base_dir, f"{subset_prefix}_{i * step_size // 1000}k")
        os.makedirs(subset_dir, exist_ok=True)

        for j in range(i):
            src_file = os.path.join(base_dir, files[j])
            dst_file = os.path.join(subset_dir, get_file_name(files[j], file_prefix, num_files))
            shutil.copy(src_file, dst_file)
        src_test_file = os.path.join(base_dir, "test.parquet")
        dst_test_file = os.path.join(subset_dir, "test.parquet")
        shutil.copy(src_test_file, dst_test_file)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Create subsets of Parquet files using Dask.")
    parser.add_argument("--directory", type=str, help="Path to the directory containing Parquet files.")
    parser.add_argument("--is-shuffled", type=bool, help="Whether the files are shuffled or not.")
    args = parser.parse_args()

    file_prefix = (
        "shuffle_train"
        if args.is_shuffled
        else "train"
    )
    subset_prefix = "subset"
    step_size = 500_000  # 500k

    create_subsets(args.directory, file_prefix, subset_prefix, step_size)
    print(f'Finished creating subsets of Parquet files in {args.directory}.')