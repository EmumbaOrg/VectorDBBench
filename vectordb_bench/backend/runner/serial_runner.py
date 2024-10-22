import random
import time
import logging
import traceback
import concurrent
import multiprocessing as mp
import math
import psutil

import numpy as np
import pandas as pd

from ..clients import api
from ...metric import calc_ndcg, calc_recall, get_ideal_dcg
from ...models import LoadTimeoutError, PerformanceTimeoutError
from .. import utils
from ... import config
from vectordb_bench.backend.dataset import DatasetManager

NUM_PER_BATCH = config.NUM_PER_BATCH
LOAD_MAX_TRY_COUNT = 10
WAITTING_TIME = 60

log = logging.getLogger(__name__)

class SerialInsertRunner:
    def __init__(self, db: api.VectorDB, dataset: DatasetManager, normalize: bool, timeout: float | None = None):
        self.timeout = timeout if isinstance(timeout, (int, float)) else None
        self.dataset = dataset
        self.db = db
        self.normalize = normalize

    def task(self) -> int:
        count = 0
        with self.db.init():
            log.info(f"({mp.current_process().name:16}) Start inserting embeddings in batch {config.NUM_PER_BATCH}")
            start = time.perf_counter()
            for data_df in self.dataset:
                all_metadata = data_df['id'].tolist()

                emb_np = np.stack(data_df['emb'])
                if self.normalize:
                    log.debug("normalize the 100k train data")
                    all_embeddings = (emb_np / np.linalg.norm(emb_np, axis=1)[:, np.newaxis]).tolist()
                else:
                    all_embeddings = emb_np.tolist()
                del(emb_np)
                log.debug(f"batch dataset size: {len(all_embeddings)}, {len(all_metadata)}")

                insert_count, error = self.db.insert_embeddings(
                    embeddings=all_embeddings,
                    metadata=all_metadata,
                )
                if error is not None:
                    raise error

                assert insert_count == len(all_metadata)
                count += insert_count
                if count % 100_000 == 0:
                    log.info(f"({mp.current_process().name:16}) Loaded {count} embeddings into VectorDB")

            log.info(f"({mp.current_process().name:16}) Finish loading all dataset into VectorDB, dur={time.perf_counter()-start}")
            return count

    def endless_insert_data(self, all_embeddings, all_metadata, left_id: int = 0) -> int:
        with self.db.init():
            # unique id for endlessness insertion
            all_metadata = [i+left_id for i in all_metadata]

            NUM_BATCHES = math.ceil(len(all_embeddings)/NUM_PER_BATCH)
            log.info(f"({mp.current_process().name:16}) Start inserting {len(all_embeddings)} embeddings in batch {NUM_PER_BATCH}")
            count = 0
            for batch_id in range(NUM_BATCHES):
                retry_count = 0
                already_insert_count = 0
                metadata = all_metadata[batch_id*NUM_PER_BATCH : (batch_id+1)*NUM_PER_BATCH]
                embeddings = all_embeddings[batch_id*NUM_PER_BATCH : (batch_id+1)*NUM_PER_BATCH]

                log.debug(f"({mp.current_process().name:16}) batch [{batch_id:3}/{NUM_BATCHES}], Start inserting {len(metadata)} embeddings")
                while retry_count < LOAD_MAX_TRY_COUNT:
                    insert_count, error = self.db.insert_embeddings(
                        embeddings=embeddings[already_insert_count :],
                        metadata=metadata[already_insert_count :],
                    )
                    already_insert_count += insert_count
                    if error is not None:
                        retry_count += 1
                        time.sleep(WAITTING_TIME)

                        log.info(f"Failed to insert data, try {retry_count} time")
                        if retry_count >= LOAD_MAX_TRY_COUNT:
                            raise error
                    else:
                        break
                log.debug(f"({mp.current_process().name:16}) batch [{batch_id:3}/{NUM_BATCHES}], Finish inserting {len(metadata)} embeddings")

                assert already_insert_count == len(metadata)
                count += already_insert_count
            log.info(f"({mp.current_process().name:16}) Finish inserting {len(all_embeddings)} embeddings in batch {NUM_PER_BATCH}")
        return count

    @utils.time_it
    def _insert_all_batches(self) -> int:
        """Performance case only"""
        with concurrent.futures.ProcessPoolExecutor(mp_context=mp.get_context('spawn'), max_workers=1) as executor:
            future = executor.submit(self.task)
            try:
                count = future.result(timeout=self.timeout)
            except TimeoutError as e:
                msg = f"VectorDB load dataset timeout in {self.timeout}"
                log.warning(msg)
                for pid, _ in executor._processes.items():
                    psutil.Process(pid).kill()
                raise PerformanceTimeoutError(msg) from e
            except Exception as e:
                log.warning(f"VectorDB load dataset error: {e}")
                raise e from e
            else:
                return count

    def run_endlessness(self) -> int:
        """run forever util DB raises exception or crash"""
        # datasets for load tests are quite small, can fit into memory
        # only 1 file
        data_df = [data_df for data_df in self.dataset][0]
        all_embeddings, all_metadata = np.stack(data_df["emb"]).tolist(), data_df['id'].tolist()

        start_time = time.perf_counter()
        max_load_count, times = 0, 0
        try:
            with self.db.init():
                self.db.ready_to_load()
            while time.perf_counter() - start_time < self.timeout:
                count = self.endless_insert_data(all_embeddings, all_metadata, left_id=max_load_count)
                max_load_count += count
                times += 1
                log.info(f"Loaded {times} entire dataset, current max load counts={utils.numerize(max_load_count)}, {max_load_count}")
        except Exception as e:
            log.info(f"Capacity case load reach limit, insertion counts={utils.numerize(max_load_count)}, {max_load_count}, err={e}")
            traceback.print_exc()
            return max_load_count
        else:
            msg = f"capacity case load timeout in {self.timeout}s"
            log.info(msg)
            raise LoadTimeoutError(msg)

    def run(self) -> int:
        count, dur = self._insert_all_batches()
        return count


class SerialSearchRunner:
    def __init__(
        self,
        db: api.VectorDB,
        test_data: list[list[float]],
        ground_truth: pd.DataFrame,
        k: int = 100,
        filters: dict | None = None,
    ):
        self.db = db
        self.k = k
        self.filters = filters

        if isinstance(test_data[0], np.ndarray):
            self.test_data = [query.tolist() for query in test_data]
        else:
            self.test_data = test_data
        self.ground_truth = ground_truth

    def search(self, args: tuple[list, pd.DataFrame]):
        log.info(f"{mp.current_process().name:14} start search the entire test_data to get recall and latency")
        with self.db.init():
            test_data, ground_truth = args
            ideal_dcg = get_ideal_dcg(self.k)

            log.debug(f"test dataset size: {len(test_data)}")
            log.debug(f"ground truth size: {ground_truth.columns}, shape: {ground_truth.shape}")

            latencies, recalls, ndcgs = [], [], []
            for idx, emb in enumerate(test_data):
                s = time.perf_counter()
                try:
                    results = self.db.search_embedding(
                        emb,
                        self.k,
                        self.filters,
                    )

                except Exception as e:
                    log.warning(f"VectorDB search_embedding error: {e}")
                    traceback.print_exc(chain=True)
                    raise e from None

                latencies.append(time.perf_counter() - s)

                gt = ground_truth['neighbors_id'][idx]
                recalls.append(calc_recall(self.k, gt[:self.k], results))
                ndcgs.append(calc_ndcg(gt[:self.k], results, ideal_dcg))


                if len(latencies) % 100 == 0:
                    log.debug(f"({mp.current_process().name:14}) search_count={len(latencies):3}, latest_latency={latencies[-1]}, latest recall={recalls[-1]}")

        avg_latency = round(np.mean(latencies), 4)
        avg_recall = round(np.mean(recalls), 4)
        avg_ndcg = round(np.mean(ndcgs), 4)
        cost = round(np.sum(latencies), 4)
        p99 = round(np.percentile(latencies, 99), 4)
        log.info(
            f"{mp.current_process().name:14} search entire test_data: "
            f"cost={cost}s, "
            f"queries={len(latencies)}, "
            f"avg_recall={avg_recall}, "
            f"avg_ndcg={avg_ndcg},"
            f"avg_latency={avg_latency}, "
            f"p99={p99}"
         )
        return (avg_recall, avg_ndcg, p99)


    def _run_in_subprocess(self) -> tuple[float, float]:
        with concurrent.futures.ProcessPoolExecutor(max_workers=1) as executor:
            future = executor.submit(self.search, (self.test_data, self.ground_truth))
            result = future.result()
            return result

    def run(self) -> tuple[float, float]:
        return self._run_in_subprocess()

class SerialChurnRunner:
    def __init__(self, db: api.VectorDB, dataset: DatasetManager, test_data: list[list[float]], ground_truth: pd.DataFrame, 
                 p_churn: float, cycles: int, normalize: bool = False, k: int = 100, timeout: float | None = None):
        self.db = db
        self.dataset = dataset
        self.p_churn = p_churn / 100
        self.cycles = cycles
        self.test_data = test_data
        self.ground_truth = ground_truth
        self.k = k
        self.normalize = normalize
        self.timeout = timeout if isinstance(timeout, (int, float)) else None

    def run_churn_cycle(self) -> list[dict]:
        """Runs multiple churn cycles where embeddings are deleted and reinserted."""
        results = []
        total_embeddings = self.dataset.data.size  # Use the size property from BaseDataset
        churn_size = int(total_embeddings * self.p_churn)

        # Calculate recall before the first deletion/insertion cycle
        initial_recall, initial_ndcg, initial_p99 = self._calculate_metrics()
        results.append({
            'cycle': 0,  # Pre-churn cycle
            'recall': initial_recall,
            'ndcg': initial_ndcg,
            'p99': initial_p99
        })
        log.info(f"Initial recall={initial_recall}, NDCG={initial_ndcg}, p99 latency={initial_p99}")

        # Perform the delete/insert churn for the defined number of cycles
        for cycle in range(1, self.cycles + 1):
            # Randomly select embeddings to delete
            deleted_embeddings, deleted_metadata = self._select_random_embeddings(churn_size)
            
            # Delete selected embeddings
            self._delete_embeddings(deleted_metadata)
            
            # Re-insert deleted embeddings
            self._insert_embeddings(deleted_embeddings, deleted_metadata)
            
            # Perform a search to calculate metrics
            recall, ndcg, p99 = self._calculate_metrics()
            
            # Store results for the cycle
            results.append({
                'cycle': cycle,
                'recall': recall,
                'ndcg': ndcg,
                'p99': p99
            })
            log.info(f"Cycle {cycle} completed with recall={recall}, NDCG={ndcg}, p99 latency={p99}")

        return results
    
    def _select_random_embeddings(self) -> tuple[list[list[float]], list[int]]:
        """Selects random embeddings and metadata for deletion based on self.p_churn."""
        selected_embeddings = []
        selected_metadata = []

        # Calculate the total number of embeddings in the dataset
        total_embeddings = self.dataset.data.size
        churn_size = int(total_embeddings * self.p_churn)  # Calculate churn size based on self.p_churn
        
        # Fetch embeddings from the dataset in a memory-efficient way
        current_size = 0
        for data_df in self.dataset:
            if current_size >= churn_size:
                break
            
            all_metadata = data_df['id'].tolist()
            emb_np = np.stack(data_df['emb'])
            
            # Normalize if necessary
            if self.normalize:
                all_embeddings = (emb_np / np.linalg.norm(emb_np, axis=1)[:, np.newaxis]).tolist()
            else:
                all_embeddings = emb_np.tolist()
            del emb_np
            
            # Calculate how many embeddings to take from this batch based on self.p_churn
            embeddings_in_batch = len(all_metadata)
            embeddings_to_take = int(embeddings_in_batch * self.p_churn)  # Proportional selection
            
            # Randomly shuffle and select embeddings from this batch
            combined = list(zip(all_embeddings, all_metadata))
            random.shuffle(combined)
            
            # Select the calculated number of embeddings, ensuring we don't exceed churn_size
            embeddings_to_take = min(embeddings_to_take, churn_size - current_size)
            selected_embeddings.extend([x[0] for x in combined[:embeddings_to_take]])
            selected_metadata.extend([x[1] for x in combined[:embeddings_to_take]])
            current_size += embeddings_to_take
            
            # Stop if we've selected enough embeddings
            if current_size >= churn_size:
                break
        
        return selected_embeddings, selected_metadata

    def _delete_embeddings(self, metadata: list[int]):
        """Deletes embeddings from the database."""
        with self.db.init():
            self.db.delete_embeddings(metadata)

    def _insert_embeddings(self, embeddings: list[list[float]], metadata: list[int]):
        """Inserts embeddings back into the database."""
        with self.db.init():
            self.db.insert_embeddings(embeddings, metadata)

    def _calculate_metrics(self) -> tuple[float, float, float]:
        """Calculates recall, NDCG, and latency metrics."""
        search_runner = SerialSearchRunner(self.db, self.test_data, self.ground_truth, self.k)
        return search_runner.run()

    def run(self):
        """Runs the churn process and stores results."""
        churn_results = self.run_churn_cycle()
        
        # Save results to JSON
        result_path = pathlib.Path(config.RESULTS_DIR, "churn_results.json")
        with open(result_path, 'w') as f:
            json.dump(churn_results, f, indent=4)
        
        log.info(f"Churn process completed, results saved to {result_path}")
        return churn_results
