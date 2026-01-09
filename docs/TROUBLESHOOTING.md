# Hadoop/Spark Teaching Lab - Troubleshooting Guide

## Quick Diagnostic Commands

```bash
# View all container status
docker-compose ps

# View logs for a specific service
docker-compose logs namenode
docker-compose logs resourcemanager
docker-compose logs jupyter

# Follow logs in real-time
docker-compose logs -f namenode

# Execute commands inside a container
docker exec -it namenode bash
docker exec -it jupyter bash
```

## Common Issues and Solutions

### 1. Containers Won't Start

**Symptoms:**
- `docker-compose up` shows errors
- Containers exit immediately

**Solutions:**

```bash
# Complete reset
docker-compose down -v --remove-orphans
docker system prune -f
./scripts/start-lab.sh
```

### 2. NameNode Stuck in Safe Mode

**Symptoms:**
- `Cannot create file. Name node is in safe mode`
- HDFS UI shows "Safe Mode is ON"

**Solutions:**

```bash
# Wait for DataNodes to register (usually 30 seconds)
# Or force leave safe mode:
docker exec namenode hdfs dfsadmin -safemode leave
```

### 3. YARN Shows No Nodes

**Symptoms:**
- No NodeManagers visible in YARN UI
- Jobs stuck in ACCEPTED state

**Solutions:**

```bash
# Check NodeManager logs
docker-compose logs nodemanager1

# Restart NodeManagers
docker-compose restart nodemanager1 nodemanager2
```

### 4. Spark Job Fails to Start

**Symptoms:**
- `Application submission failed`
- `No resources available`

**Solutions:**

```python
# Reduce resource requirements in SparkSession:
spark = SparkSession.builder \
    .appName("MyApp") \
    .config("spark.executor.memory", "512m") \
    .config("spark.executor.cores", "1") \
    .config("spark.executor.instances", "1") \
    .getOrCreate()
```

### 5. Out of Memory Errors

**Symptoms:**
- `java.lang.OutOfMemoryError`
- Container killed by Docker

**Solutions:**

1. Increase Docker Desktop memory to 8GB+
2. Reduce Spark memory settings:
```python
spark = SparkSession.builder \
    .config("spark.driver.memory", "512m") \
    .config("spark.executor.memory", "512m") \
    .getOrCreate()
```

### 6. Jupyter Can't Connect to Spark

**Symptoms:**
- `Py4JNetworkError`
- SparkSession creation hangs

**Solutions:**

```python
# Stop any existing SparkSession first
try:
    spark.stop()
except:
    pass

# Wait a few seconds, then create new session
import time
time.sleep(5)

spark = SparkSession.builder \
    .appName("NewApp") \
    .master("yarn") \
    .getOrCreate()
```

### 7. Port Already in Use

**Symptoms:**
- `Bind for 0.0.0.0:XXXX failed: port is already allocated`

**Solutions:**

```bash
# Find and stop conflicting process
# Windows:
netstat -ano | findstr :8888
taskkill /PID <pid> /F

# Mac/Linux:
lsof -i :8888
kill -9 <pid>

# Or use different ports in docker-compose.yml
```

### 8. DataNode Not Connecting

**Symptoms:**
- HDFS UI shows fewer than 3 live DataNodes

**Solutions:**

```bash
# Check DataNode logs
docker-compose logs datanode1

# Restart specific DataNode
docker-compose restart datanode1

# If persists, reset that DataNode's data
docker-compose stop datanode1
docker volume rm hadoop_datanode1_data
docker-compose up -d datanode1
```

## Complete Reset

If nothing else works, perform a complete reset:

```bash
# Stop everything
docker-compose down -v --remove-orphans

# Remove all images (optional - will require re-download)
docker-compose down --rmi all

# Clean up Docker
docker system prune -af
docker volume prune -f

# Start fresh
./scripts/start-lab.sh
```

## Performance Tuning

### For Machines with Limited RAM (8GB)

Edit `docker/spark/spark.env`:
```
SPARK_CONF_spark_driver_memory=512m
SPARK_CONF_spark_executor_memory=512m
SPARK_CONF_spark_executor_instances=1
```

### For Machines with More RAM (16GB+)

Edit `docker/spark/spark.env`:
```
SPARK_CONF_spark_driver_memory=2g
SPARK_CONF_spark_executor_memory=2g
SPARK_CONF_spark_executor_instances=3
```

## Getting Help

1. Run `./scripts/sanity-check.sh` and share the output
2. Collect logs: `docker-compose logs > debug.log`
3. Check container status: `docker-compose ps`
4. Share error messages from Jupyter notebook cells

