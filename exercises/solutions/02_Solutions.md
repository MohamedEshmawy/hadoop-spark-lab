# Exercise 2: Spark Fundamentals - Solutions

## TODO 1: Create an RDD
```python
numbers = spark.sparkContext.parallelize(range(1, 101), numSlices=5)
```

## TODO 2: Apply Transformations
```python
squared = numbers.map(lambda x: x ** 2)
filtered = squared.filter(lambda x: x > 500)
```

## TODO 3: Load and Explore DataFrame
```python
df = spark.read \
    .option("header", "true") \
    .option("inferSchema", "true") \
    .csv("hdfs:///user/student/data/transactions.csv")

df.printSchema()

row_count = df.count()
```

## TODO 3b: Average Transaction Amount
```python
from pyspark.sql.functions import avg

avg_result = df.agg(avg("total_amount")).collect()[0][0]
avg_amount = avg_result
```

## TODO 4: GroupBy and Aggregation
```python
top_payment_methods = df.groupBy("payment_method") \
    .agg(sum("total_amount").alias("total_sales")) \
    .orderBy(desc("total_sales")) \
    .limit(3)
```

## TODO 5: Explain the Execution Plan
```python
top_payment_methods.explain(True)
```

**Analysis:**
- Shuffle present: **Yes** - groupBy requires data exchange between partitions
- Number of stages: **2** - one for reading/mapping, one after shuffle for aggregation
- The Exchange node in the plan indicates shuffle

## Key Concepts Demonstrated:

1. **Lazy Evaluation**: `map()` and `filter()` don't execute until `collect()`
2. **RDD vs DataFrame**: DataFrames provide schema and optimizations
3. **Transformations vs Actions**: 
   - Transformations: map, filter, groupBy (return new RDD/DF)
   - Actions: collect, count, show (trigger execution)
4. **Shuffle**: groupBy causes data redistribution across the cluster

