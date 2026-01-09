# Hadoop/Spark Teaching Lab - Instructor Guide

## Learning Objectives

By the end of this lab, students will be able to:

### HDFS Fundamentals
- Understand the architecture of HDFS (NameNode, DataNodes, blocks)
- Perform basic file operations (upload, list, download, delete)
- Explain and configure replication factors
- Observe block distribution across DataNodes

### Spark Core Concepts
- Understand the difference between RDDs and DataFrames
- Distinguish between transformations (lazy) and actions (eager)
- Create and manipulate distributed datasets
- Write and submit Spark applications

### Spark SQL
- Load data from various formats (CSV, JSON, Parquet)
- Perform SQL queries on DataFrames
- Write data back to HDFS in optimized formats
- Use schemas and data type inference

### Distributed Execution
- Understand partitioning and its impact on performance
- Analyze shuffle operations and their costs
- Read Spark UI to understand stages and tasks
- Diagnose and recover from node failures

## Prerequisites

### Student Requirements
- **Hardware**: 8GB RAM minimum (16GB recommended), 20GB free disk space
- **Software**: Docker Desktop installed and running
- **Knowledge**: Basic SQL, some Python experience helpful
- **OS**: Windows 10/11, macOS, or Linux

### Instructor Preparation
1. Test the full lab on a machine similar to student machines
2. Pre-pull Docker images to save class time
3. Prepare backup USB drives with pre-built images
4. Have printed copies of troubleshooting guide
5. Test network/firewall to ensure localhost ports work

## Time Estimates

| Module | Duration |
|--------|----------|
| Setup & Orientation | 30 min |
| Exercise 1: HDFS Basics | 45 min |
| Exercise 2: Spark Fundamentals | 60 min |
| Exercise 3: Spark SQL | 45 min |
| Exercise 4: Distributed Execution | 45 min |
| Exercise 5: Break/Fix Challenge | 30 min |
| **Total** | **~4.5 hours** |

## Cluster Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Docker Network (hadoop-network)               │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │  DataNode 1  │  │  DataNode 2  │  │  DataNode 3  │           │
│  │   :9864      │  │   :9865      │  │   :9866      │           │
│  └──────────────┘  └──────────────┘  └──────────────┘           │
│          │                │                │                     │
│          └────────────────┼────────────────┘                     │
│                           │                                      │
│                    ┌──────────────┐                              │
│                    │   NameNode   │ ◄─── HDFS UI :9870          │
│                    │   :9000      │                              │
│                    └──────────────┘                              │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐                              │
│  │ NodeManager1 │  │ NodeManager2 │                              │
│  │   :8042      │  │   :8043      │                              │
│  └──────────────┘  └──────────────┘                              │
│          │                │                                      │
│          └────────────────┘                                      │
│                  │                                               │
│           ┌──────────────┐                                       │
│           │ResourceManager│ ◄─── YARN UI :8088                  │
│           └──────────────┘                                       │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │ Spark Client │  │Spark History │  │  Jupyter Lab │           │
│  │              │  │   :18080     │  │   :8888      │           │
│  └──────────────┘  └──────────────┘  └──────────────┘           │
└─────────────────────────────────────────────────────────────────┘
```

## Web UI Quick Reference

| Service | URL | Purpose |
|---------|-----|---------|
| HDFS NameNode | http://localhost:9870 | Browse filesystem, check DataNode health |
| YARN ResourceManager | http://localhost:8088 | View running applications, node status |
| Spark History Server | http://localhost:18080 | Analyze completed Spark jobs |
| Jupyter Lab | http://localhost:8888 | Interactive notebooks (token: `hadooplab`) |
| Spark Application UI | http://localhost:4040 | Live Spark job details (when running) |

## Teaching Tips

### Before Class
1. Run `./scripts/pull-images.sh` on your machine to verify everything works
2. If possible, pre-build images on a USB drive for quick distribution
3. Have students install Docker Desktop before class if possible

### During Lab Setup
1. Walk through the architecture diagram on the board
2. Have students run sanity checks together
3. Designate "tech support" students who finish early to help others

### Common Student Mistakes
- Forgetting to stop SparkSession before starting a new one
- Not understanding lazy evaluation (nothing happens until action!)
- Confusion between local file paths and HDFS paths
- Trying to read a file that hasn't been uploaded to HDFS

### Demonstration Points
- Show the HDFS UI when uploading a file - watch blocks appear
- Kill a DataNode during a job and show automatic recovery
- Use Spark UI to explain stages during a shuffle operation

## Grading Rubric (Optional)

| Criterion | Points |
|-----------|--------|
| HDFS commands executed correctly | 20 |
| Spark job runs successfully | 25 |
| Correct Spark SQL query results | 25 |
| Break/fix diagnosis correct | 20 |
| Checkpoint questions answered | 10 |
| **Total** | **100** |

