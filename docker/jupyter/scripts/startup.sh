#!/bin/bash
set -e

# Set Java 11 to match Hadoop cluster (required for Kryo serialization compatibility)
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

echo "Waiting for HDFS to be ready..."
while ! nc -z namenode 9000 2>/dev/null; do
    sleep 2
done
echo "HDFS is ready!"

echo "Waiting for YARN to be ready..."
while ! nc -z resourcemanager 8032 2>/dev/null; do
    sleep 2
done
sleep 5
echo "YARN is ready!"

echo "Starting Jupyter Lab..."
exec jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --NotebookApp.token="${JUPYTER_TOKEN:-hadooplab}"

