#!/bin/bash

# Run the first Python script using nohup and save the process ID
echo "Activating virtual environment..."
source VectorDBBench/venv/bin/activate
echo "Virtual environment activated"

echo "Changing directory to VectorDBBench..."
cd VectorDBBench/
echo "Current directory: $(pwd)"

host="172.17.0.2"
dbuser="postgres"
dbpass="admin123"
dbname="ann"

echo "Running vectordbbench with specified parameters..."
vectordbbench pgvectorhnsw --user-name $dbuser --password $dbpass --host $host --db-name $dbname --drop-old --load --skip-search-serial --skip-search-concurrent --skip-search-churn --case-type Performance1536D500K --maintenance-work-mem 8GB --max-parallel-workers 7 --num-concurrency 1 --concurrency-duration 30 --m 16 --ef-construction 128 --ef-search 64 > ../build-index-out.log 2>&1 &
VECTORDDBENCH_PID=$!
echo "vectordbbench started with PID $VECTORDDBENCH_PID"

echo "Waiting for index build to complete..."
wait $VECTORDDBENCH_PID
echo "index build completed completed"

kill $VECTORDDBENCH_PID
echo "vectordbbench index build process killed"

echo "Changing directory back to the original..."
cd ../
echo "Current directory: $(pwd)"


echo "Starting run-churn.py with nohup..."
nohup python3 VectorDBBench-churn/run-churn.py > churn-run-output.log  2>&1 &
NOHUP_PID=$!
echo "run-churn.py started with PID $NOHUP_PID"

# Wait for 15 seconds
echo "Sleeping for 15 seconds..."
sleep 15

# Run the second Python script in parallel
echo "Starting run.py..."
python3 VectorDBBench/run.py > qps-run-output.log  2>&1 & 
RUN_PY_PID=$!
echo "run.py started with PID $RUN_PY_PID"

# Wait for the second script to complete
echo "Waiting for run.py to complete..."
wait $RUN_PY_PID
echo "run.py completed"

# Kill the nohup process
echo "Killing run-churn.py with PID $NOHUP_PID..."
kill $NOHUP_PID
echo "run-churn.py killed"
