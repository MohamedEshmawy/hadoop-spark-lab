#!/bin/bash
set -e

# Wait for PostgreSQL to be ready
wait_for_postgres() {
    echo "Waiting for PostgreSQL to be ready..."
    until nc -z postgres 5432 > /dev/null 2>&1; do
        sleep 2
    done
    echo "PostgreSQL is ready!"
}

# Initialize Airflow database
init_airflow_db() {
    echo "Initializing Airflow database..."
    airflow db migrate
    echo "Airflow database initialized."
}

# Create admin user if not exists
create_admin_user() {
    echo "Creating admin user..."
    airflow users create \
        --username admin \
        --firstname Admin \
        --lastname User \
        --role Admin \
        --email admin@example.com \
        --password admin \
        2>/dev/null || echo "Admin user already exists."
}

# Create Hadoop connections
create_connections() {
    echo "Creating Airflow connections..."
    
    # HDFS connection
    airflow connections add 'hdfs_default' \
        --conn-type 'hdfs' \
        --conn-host 'namenode' \
        --conn-port 9000 \
        2>/dev/null || echo "HDFS connection already exists."
    
    # Hive connection
    airflow connections add 'hive_default' \
        --conn-type 'hive_cli' \
        --conn-host 'hiveserver2' \
        --conn-port 10000 \
        --conn-schema 'default' \
        2>/dev/null || echo "Hive connection already exists."
    
    # Spark connection
    airflow connections add 'spark_default' \
        --conn-type 'spark' \
        --conn-host 'yarn' \
        --conn-extra '{"deploy-mode": "client", "spark-home": "/opt/spark", "queue": "default"}' \
        2>/dev/null || echo "Spark connection already exists."
    
    echo "Connections created."
}

case "${AIRFLOW_MODE}" in
    webserver)
        echo "Starting Airflow Webserver..."
        wait_for_postgres
        init_airflow_db
        create_admin_user
        create_connections
        exec airflow webserver
        ;;
    scheduler)
        echo "Starting Airflow Scheduler..."
        wait_for_postgres
        # Wait for webserver to initialize DB
        sleep 15
        exec airflow scheduler
        ;;
    worker)
        echo "Starting Airflow Worker..."
        wait_for_postgres
        sleep 15
        exec airflow celery worker
        ;;
    init)
        echo "Initializing Airflow..."
        wait_for_postgres
        init_airflow_db
        create_admin_user
        create_connections
        echo "Airflow initialization complete."
        ;;
    *)
        echo "Unknown AIRFLOW_MODE: ${AIRFLOW_MODE}"
        echo "Valid modes: webserver, scheduler, worker, init"
        exit 1
        ;;
esac

