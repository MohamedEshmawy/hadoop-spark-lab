# Exercise 5: Airflow Fundamentals - Solutions

## Exercise 1.1: Airflow UI
**Answer:** The Admin > Connections menu shows configured connections to external systems including:
- `hdfs_default` - HDFS connection
- `hive_default` - Hive connection
- `spark_default` - Spark connection

## Exercise 2.1: Hello Hadoop DAG

```python
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

default_args = {
    'owner': 'student',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    'hello_hadoop',
    default_args=default_args,
    description='A simple DAG to test Hadoop connectivity',
    schedule_interval=None,
    catchup=False,
) as dag:
    
    list_hdfs = BashOperator(
        task_id='list_hdfs_root',
        bash_command='hdfs dfs -ls /',
    )
    
    check_yarn = BashOperator(
        task_id='check_yarn',
        bash_command='yarn node -list',
    )
    
    # Task dependency: list_hdfs runs before check_yarn
    list_hdfs >> check_yarn
```

## Exercise 3.1: XCom Data Processing

```python
def generate_data(**context):
    import random
    data = [random.randint(1, 100) for _ in range(10)]
    context['ti'].xcom_push(key='data', value=data)
    return data

def process_data(**context):
    data = context['ti'].xcom_pull(task_ids='generate', key='data')
    
    if data:
        stats = {
            'sum': sum(data),
            'avg': sum(data) / len(data),
            'max': max(data),
            'min': min(data),
        }
        print(f"Statistics: {stats}")
        return stats
```

## Exercise 4.1: SparkSubmit DAG

```python
spark_job = SparkSubmitOperator(
    task_id='run_spark_etl',
    application='/exercises/spark_etl_job.py',
    conn_id='spark_default',
    conf={
        'spark.master': 'yarn',
        'spark.submit.deployMode': 'client',
    },
    executor_memory='1g',
    executor_cores=1,
    num_executors=2,
)
```

## Exercise 6.1: Complex Pipeline with Branching

```python
with DAG('complex_pipeline', ...) as dag:
    
    start = EmptyOperator(task_id='start')
    
    branch = BranchPythonOperator(
        task_id='decide_branch',
        python_callable=decide_branch,
    )
    
    with TaskGroup('weekday_tasks') as weekday_tasks:
        process_weekday = BashOperator(
            task_id='process_weekday',
            bash_command='echo "Processing weekday data"',
        )
    
    with TaskGroup('weekend_tasks') as weekend_tasks:
        process_weekend = BashOperator(
            task_id='process_weekend',
            bash_command='echo "Processing weekend data"',
        )
    
    end = EmptyOperator(task_id='end', trigger_rule='none_failed_min_one_success')
    
    start >> branch
    branch >> weekday_tasks >> end
    branch >> weekend_tasks >> end
```

## Key Concepts Learned

1. **DAG Structure**
   - DAGs define task dependencies
   - Tasks are operators that perform work
   - XComs allow data passing between tasks

2. **Operators**
   - BashOperator: Run shell commands
   - PythonOperator: Run Python functions
   - SparkSubmitOperator: Submit Spark jobs

3. **Task Dependencies**
   - `>>` defines downstream dependencies
   - `<<` defines upstream dependencies
   - TaskGroups organize related tasks

4. **Scheduling**
   - schedule_interval defines run frequency
   - catchup=False prevents backfilling
   - start_date is required

