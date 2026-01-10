#!/bin/bash
set -e

# Wait for HDFS to be ready
wait_for_hdfs() {
    echo "Waiting for HDFS to be ready..."
    until hdfs dfs -ls / > /dev/null 2>&1; do
        sleep 2
    done
    echo "HDFS is ready!"
}

# Wait for PostgreSQL to be ready
wait_for_postgres() {
    echo "Waiting for PostgreSQL to be ready..."
    until pg_isready -h postgres -p 5432 -U hive > /dev/null 2>&1; do
        sleep 2
    done
    echo "PostgreSQL is ready!"
}

# Initialize HDFS directories for Hive
init_hdfs_dirs() {
    echo "Creating Hive directories in HDFS..."
    hdfs dfs -mkdir -p /user/hive/warehouse
    hdfs dfs -mkdir -p /tmp/hive
    hdfs dfs -chmod 1777 /tmp/hive
    hdfs dfs -chmod 1777 /user/hive/warehouse
    echo "HDFS directories created."
}

# Initialize Hive metastore schema
init_metastore_schema() {
    echo "Checking if metastore schema needs initialization..."
    if ! schematool -dbType postgres -info > /dev/null 2>&1; then
        echo "Initializing Hive metastore schema..."
        schematool -dbType postgres -initSchema
        echo "Metastore schema initialized."
    else
        echo "Metastore schema already exists."
    fi
}

case "${HIVE_MODE}" in
    metastore)
        echo "Starting Hive Metastore..."
        wait_for_hdfs
        wait_for_postgres
        init_hdfs_dirs
        init_metastore_schema
        exec hive --service metastore
        ;;
    hiveserver2)
        echo "Starting HiveServer2..."
        # Wait for metastore to be ready
        echo "Waiting for Hive Metastore to be ready..."
        until nc -z hive-metastore 9083 > /dev/null 2>&1; do
            sleep 2
        done
        echo "Hive Metastore is ready!"
        exec hive --service hiveserver2
        ;;
    cli)
        echo "Starting Hive CLI..."
        exec /bin/bash
        ;;
    *)
        echo "Unknown HIVE_MODE: ${HIVE_MODE}"
        echo "Valid modes: metastore, hiveserver2, cli"
        exit 1
        ;;
esac

