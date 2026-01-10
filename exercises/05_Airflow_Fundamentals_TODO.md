# Exercise 5: Apache Airflow Fundamentals

## Learning Objectives
- Understand Airflow architecture (webserver, scheduler, DAGs)
- Create and deploy DAGs (Directed Acyclic Graphs)
- Use various operators (BashOperator, PythonOperator, SparkSubmitOperator)
- Integrate Airflow with Hadoop ecosystem (HDFS, Hive, Spark)
- Monitor and troubleshoot DAG runs

## Prerequisites
- Completed HDFS, Spark, and Hive exercises
- All services running (including airflow-webserver and airflow-scheduler)

## Access Airflow UI
Open your browser and navigate to: http://localhost:8080
- Username: `admin`
- Password: `admin`

---

## Part 1: Understanding DAGs

### Exercise 1.1: Explore the Airflow UI

1. Log into the Airflow UI
2. Navigate to the DAGs page
3. Explore the following sections:
   - **Graph View**: Visual representation of task dependencies
   - **Tree View**: Historical runs with task status
   - **Code View**: View the DAG source code
   - **Task Details**: Click on a task to see logs and details

**Question:** What information can you see in the "Admin > Connections" menu?

---

## Part 2: Creating Your First DAG

### Exercise 2.1: Simple DAG with BashOperator

Create a file named `hello_hadoop.py` in `docker/airflow/dags/`:

```python
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

# TODO: Define default arguments
default_args = {
    'owner': 'student',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# TODO: Create a DAG
with DAG(
    'hello_hadoop',
    default_args=default_args,
    description='A simple DAG to test Hadoop connectivity',
    schedule_interval=None,  # Manual trigger only
    catchup=False,
) as dag:
    
    # TODO: Create a task that lists HDFS root directory
    list_hdfs = BashOperator(
        task_id='list_hdfs_root',
        bash_command='hdfs dfs -ls /',
    )
    
    # TODO: Create a task that checks YARN status
    check_yarn = BashOperator(
        task_id='check_yarn',
        bash_command='yarn node -list',
    )
    
    # TODO: Define task dependencies
    # list_hdfs should run before check_yarn
```

**Your Task:** Complete the TODO sections and trigger the DAG from the UI.

---

## Part 3: PythonOperator and XComs

### Exercise 3.1: Data Processing DAG

Create `data_processing.py`:

```python
from datetime import datetime
from airflow import DAG
from airflow.operators.python import PythonOperator

def generate_data(**context):
    """Generate sample data and push to XCom"""
    import random
    data = [random.randint(1, 100) for _ in range(10)]
    # TODO: Push data to XCom
    # Hint: context['ti'].xcom_push(key='data', value=data)
    return data

def process_data(**context):
    """Pull data from XCom and calculate statistics"""
    # TODO: Pull data from XCom
    # Hint: context['ti'].xcom_pull(task_ids='generate', key='data')
    data = None  # Replace with xcom_pull
    
    if data:
        stats = {
            'sum': sum(data),
            'avg': sum(data) / len(data),
            'max': max(data),
            'min': min(data),
        }
        print(f"Statistics: {stats}")
        return stats

# TODO: Create the DAG and tasks
```

---

## Part 4: Spark Integration

### Exercise 4.1: SparkSubmit DAG

Create `spark_etl.py`:

```python
from datetime import datetime
from airflow import DAG
from airflow.providers.apache.spark.operators.spark_submit import SparkSubmitOperator

# TODO: Create a DAG that submits a Spark job
# The Spark job should:
# 1. Read data from HDFS
# 2. Transform it
# 3. Write results back to HDFS

with DAG(
    'spark_etl_pipeline',
    start_date=datetime(2024, 1, 1),
    schedule_interval='@daily',
    catchup=False,
) as dag:
    
    # TODO: Configure SparkSubmitOperator
    spark_job = SparkSubmitOperator(
        task_id='run_spark_etl',
        application='/exercises/spark_etl_job.py',  # Your PySpark script
        conn_id='spark_default',
        # TODO: Add configuration for YARN deployment
    )
```

---

## Part 5: Hive Integration

### Exercise 5.1: Hive ETL DAG

Create `hive_etl.py`:

```python
from datetime import datetime
from airflow import DAG
from airflow.operators.bash import BashOperator

# TODO: Create a DAG that:
# 1. Creates a Hive table
# 2. Loads data into the table
# 3. Runs a query and saves results

with DAG(
    'hive_etl_pipeline',
    start_date=datetime(2024, 1, 1),
    schedule_interval=None,
    catchup=False,
) as dag:
    
    create_table = BashOperator(
        task_id='create_table',
        bash_command='''
            beeline -u "jdbc:hive2://hiveserver2:10000/default" -e "
                CREATE TABLE IF NOT EXISTS airflow_demo (
                    id INT,
                    value STRING
                )
                STORED AS PARQUET;
            "
        ''',
    )
    
    # TODO: Add tasks for loading data and running queries
```

---

## Part 6: Scheduling and Dependencies

### Exercise 6.1: Complex DAG with Multiple Dependencies

Create `complex_pipeline.py` with:
- Parallel tasks
- Task groups
- Branching logic
- Sensor waiting for file

```python
from datetime import datetime
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import BranchPythonOperator
from airflow.operators.empty import EmptyOperator
from airflow.utils.task_group import TaskGroup

def decide_branch(**context):
    """Decide which branch to take based on day of week"""
    from datetime import datetime
    if datetime.now().weekday() < 5:  # Monday-Friday
        return 'weekday_tasks.process_weekday'
    else:
        return 'weekend_tasks.process_weekend'

with DAG(
    'complex_pipeline',
    start_date=datetime(2024, 1, 1),
    schedule_interval='@daily',
    catchup=False,
) as dag:

    start = EmptyOperator(task_id='start')

    # TODO: Create a BranchPythonOperator that calls decide_branch

    # TODO: Create TaskGroups for weekday and weekend processing

    end = EmptyOperator(task_id='end', trigger_rule='none_failed_min_one_success')

    # TODO: Define the complete task flow
```

---

## Part 7: Monitoring and Debugging

### Exercise 7.1: Debugging Failed Tasks

1. Intentionally create a DAG with a failing task
2. Find the task in the UI
3. View the task logs
4. Fix the issue and retry

### Exercise 7.2: Using Airflow CLI

```bash
# List DAGs
docker exec airflow-webserver airflow dags list

# Trigger a DAG manually
docker exec airflow-webserver airflow dags trigger hello_hadoop

# View task logs
docker exec airflow-webserver airflow tasks logs hello_hadoop list_hdfs_root 2024-01-01

# Test a task without recording
docker exec airflow-webserver airflow tasks test hello_hadoop list_hdfs_root 2024-01-01
```

---

## Challenge Exercise: End-to-End Data Pipeline

Create a complete data pipeline DAG (`end_to_end_pipeline.py`) that:

1. **Extract**: Check for new data in HDFS landing zone
2. **Transform**: Run a Spark job to process the data
3. **Load**: Insert transformed data into Hive table
4. **Validate**: Run a Hive query to validate data quality
5. **Notify**: Log success/failure (or send notification)

Include:
- Proper error handling with retries
- SLA monitoring
- Task dependencies
- Parameterization using Variables

---

## Tips and Best Practices

1. **DAG Design**
   - Keep DAGs simple and focused
   - Use TaskGroups for organization
   - Set appropriate timeouts

2. **Error Handling**
   - Use `on_failure_callback` for alerting
   - Set sensible retry policies
   - Use `trigger_rule` for complex dependencies

3. **Performance**
   - Don't put heavy processing in Python operators
   - Use Spark/Hive for data processing
   - Pool resources with `pool` parameter

4. **Testing**
   - Use `airflow tasks test` before deploying
   - Write unit tests for Python functions
   - Use DAG validation in CI/CD
