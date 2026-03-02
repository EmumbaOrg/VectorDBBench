import argparse
import os
import json
from typing import List
from utils import (
    insert_data,
    process_result_file,
    process_log_file,
    get_default_dict,
    generate_csv_file,
)

parser = argparse.ArgumentParser(description="Process data")
parser.add_argument(
    "--reset-table", action="store_true", help="Reset the records in the table"
)
parser.add_argument("--csv", action="store_true", help="Generate CSV file")
parser.add_argument("--csv-logs", action="store_true", help="Add logs in CSV file")
parser.add_argument(
    "--csp-db", action="store_true", help="Connect to cloud service provider db"
)
args = parser.parse_args()


def process_directory(data_folder: str) -> List[dict]:
    data_results = []
    for root, _, files in os.walk(data_folder):
        for file in files:
            if file.startswith("."):
                continue
            if file.endswith(".json"):
                data_result = get_default_dict()
                result_file_path = os.path.join(root, file)
                log_file_path = os.path.join(root, "log.txt")
                data_result = process_result_file(result_file_path, data_result)
                if os.path.exists(log_file_path):
                    try:
                        process_log_file(log_file_path, data_result)
                    except Exception as e:
                        print(f"Error: {e}")
                        continue
                data_results.append(data_result.copy())
                print(f"logs processed for run_id: {data_result['run_id']}")
    return data_results

def save_results(data_results: List[dict], output_file: str) -> None:
    with open(output_file, 'w') as outfile:
        json.dump(data_results, outfile, indent=4)

if __name__ == "__main__":
    data_folder = "script/data/"
    output_file = "script/processed_results.json"
    data_results = process_directory(data_folder)
    save_results(data_results, output_file)

    #import pdb;
    #pdb.set_trace()
    insert_data(data_results, False, False)
    if args.csv:
        generate_csv_file(data_results, False)
    print("Data processing complete")
