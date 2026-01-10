-- Initialize databases for Hive and Airflow

-- Create Hive Metastore database and user
CREATE DATABASE hive_metastore;
CREATE USER hive WITH ENCRYPTED PASSWORD 'hive';
GRANT ALL PRIVILEGES ON DATABASE hive_metastore TO hive;

-- Connect to hive_metastore and grant schema permissions
\c hive_metastore
GRANT ALL ON SCHEMA public TO hive;

-- Create Airflow database and user
\c postgres
CREATE DATABASE airflow;
CREATE USER airflow WITH ENCRYPTED PASSWORD 'airflow';
GRANT ALL PRIVILEGES ON DATABASE airflow TO airflow;

-- Connect to airflow and grant schema permissions
\c airflow
GRANT ALL ON SCHEMA public TO airflow;

