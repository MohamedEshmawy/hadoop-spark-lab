#!/bin/bash
set -e

echo "Starting Jupyter Lab..."

# Set environment for Spark
export PYSPARK_PYTHON=/opt/conda/bin/python3
export PYSPARK_DRIVER_PYTHON=/opt/conda/bin/python3

# Wait for HDFS to be available
echo "Waiting for HDFS namenode..."
for i in {1..30}; do
    if hdfs dfs -ls / >/dev/null 2>&1; then
        echo "HDFS is available!"
        break
    fi
    echo "Waiting for HDFS... ($i/30)"
    sleep 5
done

# Start Jupyter Lab
exec jupyter lab \
    --ip=0.0.0.0 \
    --port=8888 \
    --no-browser \
    --NotebookApp.token="${JUPYTER_TOKEN:-hadooplab}" \
    --NotebookApp.notebook_dir=/home/jovyan
