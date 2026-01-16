"""
Sample DAG: Hello Hadoop
Demonstrates basic connectivity to Hadoop ecosystem from Airflow
"""
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

default_args = {
    'owner': 'teaching-lab',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    'hello_hadoop',
    default_args=default_args,
    description='Test connectivity to Hadoop ecosystem',
    schedule_interval=None,
    catchup=False,
    tags=['demo', 'hadoop'],
) as dag:
    
    # Check HDFS connectivity
    list_hdfs = BashOperator(
        task_id='list_hdfs_root',
        bash_command='hdfs dfs -ls /',
    )
    
    # Check YARN connectivity
    check_yarn = BashOperator(
        task_id='check_yarn_nodes',
        bash_command='yarn node -list',
    )
    
    # Check Hive connectivity
    check_hive = BashOperator(
        task_id='check_hive',
        bash_command='beeline -u "jdbc:hive2://hiveserver2:10000/default" -e "SHOW DATABASES;"',
    )
    
    # Create an HDFS directory for Airflow
    create_airflow_dir = BashOperator(
        task_id='create_airflow_dir',
        bash_command='hdfs dfs -mkdir -p /user/airflow && hdfs dfs -chmod 777 /user/airflow',
    )
    
    # Define task flow
    list_hdfs >> check_yarn >> check_hive >> create_airflow_dir

