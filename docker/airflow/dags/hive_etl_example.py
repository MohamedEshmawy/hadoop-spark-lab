"""
Sample DAG: Hive ETL Pipeline
Demonstrates Hive operations from Airflow
"""
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

default_args = {
    'owner': 'teaching-lab',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'retries': 2,
    'retry_delay': timedelta(minutes=2),
}

BEELINE_CMD = 'beeline -u "jdbc:hive2://hiveserver2:10000/default" --silent=true -e'

with DAG(
    'hive_etl_example',
    default_args=default_args,
    description='Example Hive ETL pipeline',
    schedule_interval=None,
    catchup=False,
    tags=['demo', 'hive', 'etl'],
) as dag:
    
    # Create database
    create_database = BashOperator(
        task_id='create_database',
        bash_command=f'{BEELINE_CMD} "CREATE DATABASE IF NOT EXISTS airflow_demo;"',
    )
    
    # Create table
    create_table = BashOperator(
        task_id='create_table',
        bash_command=f'''
            {BEELINE_CMD} "
                USE airflow_demo;
                CREATE TABLE IF NOT EXISTS daily_metrics (
                    metric_name STRING,
                    metric_value DOUBLE,
                    recorded_at TIMESTAMP
                )
                PARTITIONED BY (date_key STRING)
                STORED AS PARQUET;
            "
        ''',
    )
    
    # Insert sample data
    insert_data = BashOperator(
        task_id='insert_data',
        bash_command=f'''
            {BEELINE_CMD} "
                USE airflow_demo;
                INSERT INTO daily_metrics PARTITION (date_key='2024-01-10')
                VALUES 
                    ('cpu_usage', 75.5, current_timestamp()),
                    ('memory_usage', 62.3, current_timestamp()),
                    ('disk_io', 120.0, current_timestamp());
            "
        ''',
    )
    
    # Run aggregation query
    run_aggregation = BashOperator(
        task_id='run_aggregation',
        bash_command=f'''
            {BEELINE_CMD} "
                USE airflow_demo;
                SELECT 
                    metric_name,
                    AVG(metric_value) as avg_value,
                    MAX(metric_value) as max_value
                FROM daily_metrics
                GROUP BY metric_name;
            "
        ''',
    )
    
    # Show partitions
    show_partitions = BashOperator(
        task_id='show_partitions',
        bash_command=f'{BEELINE_CMD} "SHOW PARTITIONS airflow_demo.daily_metrics;"',
    )
    
    create_database >> create_table >> insert_data >> run_aggregation >> show_partitions

