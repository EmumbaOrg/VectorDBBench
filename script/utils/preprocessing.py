import re
import json
from typing import List


def get_default_dict() -> dict:
    data_result = {
        "case_type": "",
        "checkpoint_timeout": "",
        "conc_latency_p99_list": [],
        "conc_num_list": [],
        "conc_qps_list": [],
        "config_label": "",
        "concurrency_duration": None,
        "create_index_after_load": False,
        "create_index_before_load": False,
        "csp": "",
        "enable_seqscan": False,
        "db_case_config": {},
        "instance_type": "",
        "db_label": "",
        "drop_old": False,
        "effective_cache_size": "",
        "run_count": None,
        "index_build_time": None,
        "index_params": {},
        "index_size": "",
        "index_type": "",
        "jit": False,
        "k": None,
        "load": False,
        "load_duration": None,
        "logs": "",
        "maintenance_work_mem": "",
        "max_load_count": None,
        "max_parallel_maintenance_workers": None,
        "max_parallel_workers": None,
        "max_parallel_workers_per_gather": None,
        "max_wal_size": "",
        "max_worker_processes": None,
        "metric_type": "",
        "ndcg": None,
        "num_concurrency": None,
        "qps": None,
        "qps_per_dollar": None,
        "raw_data": {},
        "recall": None,
        "run_id": "",
        "search_concurrent": False,
        "search_params": {},
        "search_serial": False,
        "serial_latency_p99": None,
        "shared_buffers": "",
        "table_size": "",
        "vector_extension": "",
        "wal_compression": False,
        "work_mem": "",
        "db_case_config": {},
    }
    return data_result

def process_result_file(result_file_path: str, data_result: dict) -> dict:
    with open(result_file_path, 'r') as result_file:
        result_data = json.load(result_file)
        result = result_data["results"][0] # Assuming there is only one case result
        data_result["run_id"] = result_data["run_id"]
        print(f"Processing result logs of run_id: {data_result['run_id']}")
        data_result["vector_extension"] = result["task_config"]["db"]
        data_result["k"] = result["task_config"]["case_config"]["k"]
        data_result["num_concurrency"] = (
            result["task_config"]["case_config"]["concurrency_search_config"]["num_concurrency"]
        )
        data_result["concurrency_duration"] = (
            result["task_config"]["case_config"]["concurrency_search_config"]["concurrency_duration"]
        )
        data_result.update(result["metrics"])
        data_result["create_index_after_load"] = result["task_config"]["db_case_config"]["create_index_after_load"]
        data_result["create_index_before_load"] = result["task_config"]["db_case_config"]["create_index_before_load"]
        data_result["index_params"] = get_index_params(result["task_config"]["db_case_config"])
        data_result["search_params"] = get_search_params(result["task_config"]["db_case_config"])
        data_result["index_type"] = result["task_config"]["db_case_config"]["index"]
        data_result["metric_type"] = result["task_config"]["db_case_config"]["metric_type"]
        data_result["raw_data"] = result
        data_result["db_case_config"] = result["task_config"]["db_case_config"]
        data_result["config_label"] = get_config_label(
            result["task_config"]["db_case_config"]["index"],
            data_result["search_params"],
            data_result["index_params"],
        )
        data_result["index_build_time"] = data_result["build_dur"]
        del data_result["build_dur"]
    return data_result

def process_log_file(log_file_path: str, data_result: dict) -> None:
    with open(log_file_path, 'r') as log_file:
        logs = log_file.read()
        parsed_logs = parse_log_file(logs)
        data_result["instance_type"] = parsed_logs["db_instance_type"]
        data_result["csp"] = parsed_logs["db_instance_provider"]
        data_result["db_label"] = parsed_logs["db_label"]
        data_result["run_count"] = parsed_logs["run_count"]
        data_result["enable_seqscan"] = parsed_logs["db_enable_seqscan"]
        data_result["effective_cache_size"] = parsed_logs["effective_cache_size"]
        data_result["jit"] = parsed_logs["jit"]
        data_result["checkpoint_timeout"] = parsed_logs["checkpoint_timeout"]
        data_result["maintenance_work_mem"] = parsed_logs["maintenance_work_mem"]
        data_result["drop_old"] = parsed_logs["drop_old"]
        data_result["load"] = parsed_logs["load"]
        data_result["search_concurrent"] = parsed_logs["search_concurrent"]
        data_result["search_serial"] = parsed_logs["search_serial"]
        data_result["max_parallel_maintenance_workers"] = parsed_logs["max_parallel_maintenance_workers"]
        data_result["max_parallel_workers"] = parsed_logs["max_parallel_workers"]
        data_result["max_parallel_workers_per_gather"] = parsed_logs["max_parallel_workers_per_gather"]
        data_result["case_type"] = parsed_logs["case_type"]
        data_result["max_wal_size"] = parsed_logs["max_wal_size"]
        data_result["max_worker_processes"] = parsed_logs["max_worker_processes"]
        data_result["shared_buffers"] = parsed_logs["shared_buffers"]
        data_result["wal_compression"] = parsed_logs["wal_compression"]
        data_result["work_mem"] = parsed_logs["work_mem"]
        data_result["logs"] = logs

def create_key(key: str) -> str:
    return key.strip().lower().replace(' ', '_').replace('-', '_')

def parse_log_file(log_content: List[str]) -> dict:
    error_pattern = re.compile(r'WARNING.*failed to run, reason=', re.MULTILINE)
    if error_pattern.search(log_content):
        raise Exception("Error log found: The case failed to run.")
    pattern = re.compile(r'^(.*?):\s*(.*)$', re.MULTILINE)
    matches = pattern.findall(log_content)
    log_dict = {create_key(key.strip()): value.strip() for key, value in matches}
    del log_dict["current_postgresql_configurations"]
    return log_dict

def get_config_label(
    index_type: str, search_params: dict, index_params: dict
) -> str:
    config_label = f'{index_type}'
    if index_type.lower() == "ivf_flat":
        config_label = (
            config_label
            + " - lists="
            + str(index_params["lists"])
            + "; probes="
            + str(search_params["probes"])
        )
    elif index_type.lower() == "hnsw":
        config_label = (
            config_label
            + " - m="
            + str(index_params["m"])
            + "; ef_c=" 
            + str(index_params["ef_construction"])
            + "; ef_s=" + str(search_params["ef_search"])
        )
    elif index_type.lower() == "streaming_diskann":
        config_label = (
            config_label
            + " - storage_layout="
            + str(index_params["storage_layout"])
            + "; num_neighbors=" 
            + str(index_params["num_neighbors"])
            + "; search_list_size="
            + str(search_params["search_list_size"])
            + "; max_alpha="
            + str(search_params["max_alpha"])
            + "; num_dimensions="
            + str(search_params["num_dimensions"])
            + "; num_bits_per_dimension="
            + str(search_params["num_bits_per_dimension"])
            + "; query_search_list_size="
            + str(search_params["query_search_list_size"])
            + "; query_rescore="
            + str(search_params["query_rescore"])
        )
    return config_label

def get_index_params(db_case_config: dict) -> dict:
    index_params = {}
    if db_case_config["index"].lower() == "hnsw":
        index_params["m"] = db_case_config["m"]
        index_params["ef_construction"] = db_case_config["ef_construction"]
    elif db_case_config["index"].lower() == "ivf_flat":
        index_params["lists"] = db_case_config["lists"]
    elif db_case_config["index"].lower() == "streaming_diskann":
        index_params["storage_layout"] = db_case_config["storage_layout"]
        index_params["num_neighbors"] = db_case_config["num_neighbors"]
        index_params["search_list_size"] = db_case_config["search_list_size"]
        index_params["max_alpha"] = db_case_config["max_alpha"]
        index_params["num_dimensions"] = db_case_config["num_dimensions"]
        index_params["num_bits_per_dimension"] = db_case_config["num_bits_per_dimension"]
    return index_params

def get_search_params(db_case_config: dict) -> dict:
    search_params = {}
    if db_case_config["index"].lower() == "hnsw":
        search_params["ef_search"] = db_case_config["ef_search"]
    elif db_case_config["index"].lower() == "ivf_flat":
        search_params["probes"] = db_case_config["probes"]
    elif db_case_config["index"].lower() == "streaming_diskann":
        search_params["query_search_list_size"] = db_case_config["query_search_list_size"]
        search_params["query_rescore"] = db_case_config["query_rescore"]
    return search_params
