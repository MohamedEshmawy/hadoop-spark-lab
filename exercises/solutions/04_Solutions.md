# Exercise 4: Hive Fundamentals - Solutions

## Exercise 1.1: Default Databases
**Answer:** By default, Hive has a `default` database.

## Exercise 1.2: SparkSession with Hive Support
```python
spark = SparkSession.builder \
    .appName("HiveExercises") \
    .config("hive.metastore.uris", "thrift://hive-metastore:9083") \
    .enableHiveSupport() \
    .getOrCreate()
```

## Exercise 2.1: Create Database
```sql
CREATE DATABASE IF NOT EXISTS sales_db;
```

## Exercise 2.2: Create Managed Table
```sql
CREATE TABLE IF NOT EXISTS customers (
    customer_id INT,
    name STRING,
    email STRING,
    signup_date DATE
)
STORED AS PARQUET;
```

## Exercise 2.3: Create External Table
```sql
CREATE EXTERNAL TABLE IF NOT EXISTS products (
    product_id INT,
    name STRING,
    category STRING,
    price DOUBLE
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/hive/external/products'
TBLPROPERTIES ('skip.header.line.count'='1');
```

## Exercise 3.1: Create Partitioned Table
```sql
CREATE TABLE IF NOT EXISTS sales (
    sale_id INT,
    product_id INT,
    quantity INT,
    amount DOUBLE,
    sale_date DATE
)
PARTITIONED BY (year INT, month INT)
STORED AS PARQUET;
```

## Exercise 3.2: Query with Partition Pruning
```sql
SELECT * FROM sales WHERE year = 2024 AND month = 1;
```

## Exercise 4.1: Aggregation Query
```sql
SELECT 
    year, 
    month, 
    SUM(amount) as total_sales,
    COUNT(*) as num_transactions
FROM sales
GROUP BY year, month
ORDER BY year, month;
```

## Exercise 4.2: JOIN Operations
```sql
SELECT 
    p.name as product_name,
    p.category,
    s.quantity,
    s.amount
FROM sales s
JOIN products p ON s.product_id = p.product_id;
```

## Exercise 5.1: Window Functions
```sql
SELECT 
    sale_id,
    sale_date,
    amount,
    SUM(amount) OVER (ORDER BY sale_date ROWS UNBOUNDED PRECEDING) as running_total
FROM sales
ORDER BY sale_date;
```

## Exercise 5.2: Create View
```sql
CREATE VIEW IF NOT EXISTS monthly_summary AS
SELECT 
    year,
    month,
    SUM(amount) as total_sales,
    AVG(amount) as avg_sale,
    COUNT(*) as num_sales
FROM sales
GROUP BY year, month;
```

## Key Concepts Learned

1. **Managed vs External Tables**
   - Managed: Hive controls both metadata and data
   - External: Hive only controls metadata; data persists after DROP

2. **Partitioning Benefits**
   - Reduces data scanned for queries filtering on partition columns
   - Creates directory structure: table/year=2024/month=1/

3. **HiveQL vs SQL**
   - Very similar to standard SQL
   - Additional features: PARTITIONED BY, STORED AS, LOCATION

4. **Spark + Hive Integration**
   - SparkSQL can use Hive Metastore for shared catalog
   - Enables consistent table definitions across tools

