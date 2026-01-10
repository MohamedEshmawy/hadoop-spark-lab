"""
Sample DAG: Spark ETL Pipeline
Demonstrates Spark job submission from Airflow
"""
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.providers.apache.spark.operators.spark_submit import SparkSubmitOperator

default_args = {
    'owner': 'teaching-lab',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'retries': 2,
    'retry_delay': timedelta(minutes=2),
}

with DAG(
    'spark_etl_example',
    default_args=default_args,
    description='Example Spark ETL pipeline',
    schedule_interval=None,
    catchup=False,
    tags=['demo', 'spark', 'etl'],
) as dag:
    
    # Create sample data in HDFS
    create_sample_data = BashOperator(
        task_id='create_sample_data',
        bash_command='''
            echo "id,name,value" > /tmp/sample.csv
            echo "1,item1,100" >> /tmp/sample.csv
            echo "2,item2,200" >> /tmp/sample.csv
            echo "3,item3,300" >> /tmp/sample.csv
            hdfs dfs -mkdir -p /user/airflow/input
            hdfs dfs -put -f /tmp/sample.csv /user/airflow/input/
        ''',
    )
    
    # Run Spark Pi as a test (using built-in example)
    run_spark_pi = BashOperator(
        task_id='run_spark_pi',
        bash_command='''
            spark-submit \
                --master yarn \
                --deploy-mode client \
                --class org.apache.spark.examples.SparkPi \
                /opt/spark/examples/jars/spark-examples_2.12-3.5.0.jar 10
        ''',
    )
    
    # Run PySpark script inline
    run_pyspark_transform = BashOperator(
        task_id='run_pyspark_transform',
        bash_command='''
            spark-submit --master yarn --deploy-mode client /dev/stdin << 'EOF'
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("AirflowETL").getOrCreate()

# Read sample data
df = spark.read.option("header", "true").csv("hdfs:///user/airflow/input/sample.csv")

# Transform: add a computed column
df = df.withColumn("doubled_value", df["value"].cast("int") * 2)

# Write output
df.write.mode("overwrite").parquet("hdfs:///user/airflow/output/transformed")

print("ETL Complete!")
spark.stop()
EOF
        ''',
    )
    
    # Verify output
    verify_output = BashOperator(
        task_id='verify_output',
        bash_command='hdfs dfs -ls /user/airflow/output/transformed',
    )
    
    create_sample_data >> run_spark_pi >> run_pyspark_transform >> verify_output

