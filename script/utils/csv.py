import os
import csv

def generate_csv_file(data, logs=False):
    csv_file = "script/results.csv"
    if os.path.exists(csv_file):
        os.remove(csv_file)
    for record in data:
        if not logs:
            record.pop("logs", None)  # Remove 'logs' key from record dictionary
        with open(csv_file, "a", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=record.keys())
            if f.tell() == 0:
                writer.writeheader()
            writer.writerow(record)