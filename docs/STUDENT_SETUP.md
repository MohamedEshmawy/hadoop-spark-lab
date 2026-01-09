# Hadoop/Spark Teaching Lab - Student Setup Guide

## Prerequisites

Before starting, ensure you have:

1. **Docker Desktop** installed and running
   - Windows/Mac: Download from https://www.docker.com/products/docker-desktop
   - Linux: Install Docker Engine and Docker Compose

2. **System Requirements**
   - RAM: 8GB minimum (16GB recommended)
   - Disk: 20GB free space
   - CPU: 4 cores recommended

3. **Docker Settings** (Docker Desktop → Settings → Resources)
   - Memory: At least 6GB allocated to Docker
   - CPUs: At least 4 CPUs allocated
   - Disk: At least 20GB

## Quick Start (One Command)

### Windows (PowerShell)
```powershell
.\scripts\start-lab.ps1
```

### Mac/Linux (Bash)
```bash
./scripts/start-lab.sh
```

The first startup will take 5-10 minutes to download and build images.

## Verify Your Setup

Run the sanity check script:

```bash
./scripts/sanity-check.sh
```

All checks should pass (green ✓).

## Accessing the Lab

Once started, open these URLs in your browser:

| Service | URL | What You'll Use It For |
|---------|-----|------------------------|
| **Jupyter Lab** | http://localhost:8888 | Running notebooks and exercises |
| **HDFS Browser** | http://localhost:9870 | Viewing files in HDFS |
| **YARN UI** | http://localhost:8088 | Monitoring running jobs |
| **Spark History** | http://localhost:18080 | Analyzing completed jobs |

**Jupyter Token:** `hadooplab`

## Lab Structure

```
hadoop-spark-lab/
├── notebooks/           # Jupyter notebooks for exercises
│   ├── 01_HDFS_Basics.ipynb
│   ├── 02_Spark_Fundamentals.ipynb
│   ├── 03_Spark_SQL.ipynb
│   ├── 04_Distributed_Execution.ipynb
│   └── 05_Break_Fix_Challenge.ipynb
├── exercises/           # Exercise files with TODOs
├── data/               # Sample datasets
│   ├── sales/          # Sales transaction data
│   └── products/       # Product catalog
└── scripts/            # Utility scripts
```

## Working with HDFS

From Jupyter notebooks, you can access HDFS using the `hdfs` command:

```python
!hdfs dfs -ls /
!hdfs dfs -put data/sample.csv /user/data/
!hdfs dfs -cat /user/data/sample.csv
```

## Starting Spark

In any notebook, initialize Spark like this:

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("MyApp") \
    .master("yarn") \
    .getOrCreate()
```

## Stopping the Lab

When you're done:

### Windows
```powershell
.\scripts\stop-lab.ps1
```

### Mac/Linux
```bash
./scripts/stop-lab.sh
```

Your work in notebooks is automatically saved.

## Troubleshooting Quick Fixes

### "Container not starting"
```bash
docker-compose down -v
./scripts/start-lab.sh
```

### "Out of memory"
- Increase Docker memory allocation to 8GB+
- Reduce executor memory in notebooks

### "Connection refused to localhost:XXXX"
- Wait 1-2 minutes for services to fully start
- Run `./scripts/sanity-check.sh` to verify

### "HDFS file not found"
- Check that you uploaded the file: `!hdfs dfs -ls /`
- Verify the path is correct (starts with `/`)

See `docs/TROUBLESHOOTING.md` for detailed solutions.

