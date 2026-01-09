# Exercise 3: Spark SQL - Solutions

## TODO 1: Load Data from Multiple Formats
```python
transactions = spark.read \
    .option("header", "true") \
    .option("inferSchema", "true") \
    .csv("hdfs:///user/student/data/transactions.csv")

products = spark.read.json("hdfs:///user/student/data/catalog.json")

transactions.createOrReplaceTempView("transactions")
products.createOrReplaceTempView("products")
```

## TODO 2: Sales by Region and Month
```sql
SELECT 
    store_region,
    MONTH(TO_DATE(transaction_date, 'yyyy-MM-dd')) as month,
    COUNT(*) as transaction_count,
    ROUND(SUM(total_amount), 2) as total_sales
FROM transactions
GROUP BY store_region, MONTH(TO_DATE(transaction_date, 'yyyy-MM-dd'))
ORDER BY store_region, month
```

## TODO 3: Top Selling Categories
```sql
SELECT 
    p.category,
    COUNT(*) as total_transactions,
    ROUND(SUM(t.total_amount), 2) as total_revenue
FROM transactions t
JOIN products p ON t.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC
LIMIT 5
```

## TODO 4: Profit Margin Calculation
```sql
SELECT 
    p.category,
    ROUND(SUM(t.total_amount), 2) as revenue,
    ROUND(SUM(p.cost_price * t.quantity), 2) as cost,
    ROUND((SUM(t.total_amount) - SUM(p.cost_price * t.quantity)) / SUM(t.total_amount) * 100, 2) as profit_margin_pct
FROM transactions t
JOIN products p ON t.product_id = p.product_id
GROUP BY p.category
ORDER BY profit_margin_pct DESC
```

## TODO 5: Write to Parquet
```python
profit_margins.write \
    .mode("overwrite") \
    .parquet("hdfs:///user/student/output/profit_margins")
```

## Bonus: Best Region per Category
```sql
WITH ranked AS (
    SELECT 
        p.category,
        t.store_region,
        SUM(t.total_amount) as total_sales,
        ROW_NUMBER() OVER (PARTITION BY p.category ORDER BY SUM(t.total_amount) DESC) as rn
    FROM transactions t
    JOIN products p ON t.product_id = p.product_id
    GROUP BY p.category, t.store_region
)
SELECT category, store_region, total_sales
FROM ranked
WHERE rn = 1
ORDER BY total_sales DESC
```

## Key Concepts:
- **Schema inference** saves time but check for correctness
- **Temporary views** allow SQL syntax on DataFrames
- **JOIN optimization**: Spark uses broadcast join for small tables
- **Parquet**: Columnar format with compression, ideal for analytics

