import os
import argparse
import numpy as np
import pandas as pd
import faiss
from ast import literal_eval
from typing import Optional
import time


def load_csv(path: str):
    df = pd.read_csv(path)
    if 'emb' not in df.columns:
        raise ValueError(f"CSV file missing 'emb' column: {path}")
    
    df['emb'] = df['emb'].apply(literal_eval)
    
    if 'id' not in df.columns:
        df.insert(0, 'id', range(len(df)))
    return df


def load_npy(path: str):
    arr = np.load(path)
    df = pd.DataFrame({
        'id': range(arr.shape[0]),
        'emb': arr.tolist()
    })
    return df

def load_vectors(path: str) -> pd.DataFrame:
    if path.endswith('.csv'):
        return load_csv(path)
    elif path.endswith('.npy'):
        return load_npy(path)
    else:
        raise ValueError(f"Unsupported file format: {path}")

def compute_ground_truth(train_vectors: np.ndarray, test_vectors: np.ndarray, top_k: int = 10):
    dim = train_vectors.shape[1]
    index = faiss.IndexFlatL2(dim)
    index.add(train_vectors)
    _, indices = index.search(test_vectors, top_k)
    return indices

def save_ground_truth(df_path: str, indices: np.ndarray):
    df = pd.DataFrame({
        "id": np.arange(indices.shape[0]),
        "neighbors_id": indices.tolist()
    })
    df.to_parquet(df_path, index=False)
    print(f"✅ Ground truth saved successfully: {df_path}")

def main(train_path: str, test_path: str, output_dir: str,
         label_path: Optional[str] = None, top_k: int = 10):
    os.makedirs(output_dir, exist_ok=True)
    # Start timestamp
    start_time = time.time()
    print(f"⏱️  Starting conversion process at {time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(start_time))} ...")

    print("📥 Loading training data...")
    train_df = load_vectors(train_path)
    print("📥 Loading query data...")
    test_df = load_vectors(test_path)
    # Extract vectors and convert to numpy
    train_vectors = np.array(train_df['emb'].to_list(), dtype='float32')
    test_vectors = np.array(test_df['emb'].to_list(), dtype='float32')
    # Save parquet files retaining all fields
    train_df.to_parquet(os.path.join(output_dir, 'train.parquet'), index=False)
    print(f"✅ train.parquet saved successfully, {len(train_df)} records total")
    test_df.to_parquet(os.path.join(output_dir, 'test.parquet'), index=False)
    print(f"✅ test.parquet saved successfully, {len(test_df)} records total")
    # Compute ground truth
    print("🔍 Computing Ground Truth (nearest neighbors)...")
    gt_indices = compute_ground_truth(train_vectors, test_vectors, top_k=top_k)
    save_ground_truth(os.path.join(output_dir, 'neighbors.parquet'), gt_indices)
    # Load and save label file (if provided)
    if label_path:
        print("📥 Loading label file...")
        label_df = pd.read_csv(label_path)
        if 'labels' not in label_df.columns:
            raise ValueError("Label file must contain 'labels' column")
        label_df['labels'] = label_df['labels'].apply(literal_eval)
        label_df.to_parquet(os.path.join(output_dir, 'scalar_labels.parquet'), index=False)
        print("✅ Label file saved as scalar_labels.parquet")

    # End timestamp and elapsed time
    end_time = time.time()
    print(f"⏱️  Finished at {time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(end_time))}")
    print(f"⏳ Total elapsed time: {end_time - start_time:.2f} seconds")
    

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Convert CSV/NPY vectors to VectorDBBench data format (retaining all columns)")
    parser.add_argument("--train", required=True, help="Training data path (CSV or NPY)")
    parser.add_argument("--test", required=True, help="Query data path (CSV or NPY)")
    parser.add_argument("--out", required=True, help="Output directory")
    parser.add_argument("--labels", help="Label CSV path (optional)")
    parser.add_argument("--topk", type=int, default=10, help="Ground truth")
    args = parser.parse_args()
    main(args.train, args.test, args.out, args.labels, args.topk)