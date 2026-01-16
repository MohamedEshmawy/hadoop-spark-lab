#!/bin/bash
set -e

# Combined entrypoint for Jupyter + Airflow image
# SERVICE_MODE determines which service to run: jupyter, webserver, scheduler

echo "Starting service in ${SERVICE_MODE} mode..."

case "${SERVICE_MODE}" in
    jupyter)
        echo "Starting Jupyter Lab..."
        # Switch to jovyan user for Jupyter
        exec su jovyan -c "/jupyter-startup.sh"
        ;;
    
    webserver)
        echo "Starting Airflow Webserver..."
        # Wait for database to be ready
        sleep 10
        
        # Initialize database if needed
        airflow db migrate
        
        # Create admin user if it doesn't exist
        airflow users create \
            --username admin \
            --password admin \
            --firstname Admin \
            --lastname User \
            --role Admin \
            --email admin@example.com 2>/dev/null || true
        
        # Start webserver
        exec airflow webserver --port 8080
        ;;
    
    scheduler)
        echo "Starting Airflow Scheduler..."
        # Wait for webserver to initialize the database
        sleep 15
        
        # Start scheduler
        exec airflow scheduler
        ;;
    
    *)
        echo "Unknown SERVICE_MODE: ${SERVICE_MODE}"
        echo "Valid options: jupyter, webserver, scheduler"
        exit 1
        ;;
esac
