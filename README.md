# Hadoop/Spark Teaching Lab

A Docker-based environment for learning Hadoop HDFS and Apache Spark. This lab runs entirely on a single PC, simulating a realistic distributed cluster for hands-on learning.

## Quick Start

### Prerequisites
- Docker Desktop installed and running
- 8GB RAM minimum (16GB recommended)
- 20GB free disk space

### Option 1: Use Pre-built Images (Recommended - Fastest)

**Windows (PowerShell):**
```powershell
.\scripts\pull-images.ps1 mohamedeshmawy
.\scripts\start-lab.ps1
```

**Mac/Linux (Bash):**
```bash
./scripts/pull-images.sh mohamedeshmawy
./scripts/start-lab.sh
```

This pulls pre-built images from Docker Hub (takes 5-10 minutes depending on internet speed).

### Option 2: Build Images Locally

If you prefer to build images from scratch:

**Windows (PowerShell):**
```powershell
.\scripts\build-images.ps1
.\scripts\start-lab.ps1
```

**Mac/Linux (Bash):**
```bash
./scripts/build-images.sh
./scripts/start-lab.sh
```

This builds all images locally (takes 20-30 minutes depending on your PC).

## Web UIs

| Service | URL | Purpose |
|---------|-----|---------|
| HDFS NameNode | http://localhost:9870 | Browse filesystem, DataNode health |
| YARN ResourceManager | http://localhost:8088 | Running applications, node status |
| Spark History Server | http://localhost:18080 | Completed Spark job analysis |
| HiveServer2 Web UI | http://localhost:10002 | Hive query execution and monitoring |
| Airflow Web UI | http://localhost:8080 | Workflow orchestration and DAG management |
| Jupyter Lab | http://localhost:8888 | Interactive notebooks with PySpark |
| Spark App UI | http://localhost:4040 | Live Spark job details (when running) |

**Jupyter Token:** `hadooplab`
**Airflow Credentials:** `airflow` / `airflow`

## Cluster Architecture

```
┌────────────────────────────────────────────────────────────────┐
│                    Docker Network (hadoopnet)                  │
│                                                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │  DataNode 1  │  │  DataNode 2  │  │  DataNode 3  │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│         │                 │                  │                 │
│         └─────────────────┼──────────────────┘                 │
│                           ▼                                    │
│                    ┌────────────┐                              │
│                    │  NameNode  │ ← HDFS UI :9870             │
│                    └────────────┘                              │
│                                                                │
│  ┌──────────────┐  ┌──────────────┐                           │
│  │NodeManager 1 │  │NodeManager 2 │                           │
│  └──────────────┘  └──────────────┘                           │
│         │                 │                                    │
│         └─────────────────┘                                    │
│                    ▼                                           │
│          ┌──────────────────┐                                  │
│          │ResourceManager   │ ← YARN UI :8088                 │
│          └──────────────────┘                                  │
│                                                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │Spark History │  │  Jupyter Lab │  │ HiveServer2  │         │
│  │   Server    │  │  with PySpark│  │  (Hive SQL)  │         │
│  │ :18080      │  │    :8888     │  │   :10002     │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│                                                                │
│  ┌──────────────────────────────────────────────────┐         │
│  │         Hive Metastore (Thrift :9083)            │         │
│  │         PostgreSQL Database (:5432)              │         │
│  └──────────────────────────────────────────────────┘         │
│                                                                │
│  ┌──────────────────────────────────────────────────┐         │
│  │  Airflow Webserver :8080 & Scheduler             │         │
│  │  (Workflow Orchestration & DAG Management)       │         │
│  └──────────────────────────────────────────────────┘         │
└────────────────────────────────────────────────────────────────┘
```

## Lab Exercises

| # | Exercise | Duration | Topics |
|---|----------|----------|--------|
| 1 | HDFS Basics | 45 min | Upload, list, blocks, replication |
| 2 | Spark Fundamentals | 60 min | RDD, DataFrame, transformations, actions |
| 3 | Spark SQL | 45 min | CSV/JSON/Parquet, SQL queries, joins |
| 4 | Distributed Execution | 45 min | Partitions, shuffle, stages, Spark UI |
| 5 | Break/Fix Challenge | 30 min | Fault tolerance, recovery |

## Directory Structure

```
hadoop-spark-lab/
├── docker-compose.yml      # Cluster definition
├── docker/                 # Dockerfiles and configs
│   ├── hadoop/             # Hadoop HDFS/YARN
│   ├── spark/              # Spark & History Server
│   ├── jupyter/            # Jupyter Lab with PySpark
│   ├── hive/               # Hive Metastore & HiveServer2
│   ├── airflow/            # Airflow Webserver & Scheduler
│   └── postgres/           # PostgreSQL initialization
├── notebooks/              # Completed example notebooks
├── exercises/              # TODO versions for students
│   └── solutions/          # Answer keys
├── data/                   # Sample datasets
├── scripts/                # Startup and utility scripts
│   ├── start-lab.sh        # Start the cluster
│   ├── stop-lab.sh         # Stop the cluster
│   ├── build-images.sh     # Build Docker images
│   ├── tag-images.sh       # Tag for Docker Hub
│   └── push-images.sh      # Push to Docker Hub
└── docs/                   # Instructor and student guides
```

## Docker Hub Images

Pre-built images are available on Docker Hub for quick setup:

- `mohamedeshmawy/hadoop-spark-lab-hadoop:latest` - Hadoop HDFS/YARN
- `mohamedeshmawy/hadoop-spark-lab-spark:latest` - Spark & History Server
- `mohamedeshmawy/hadoop-spark-lab-hive:latest` - Apache Hive
- `mohamedeshmawy/hadoop-spark-lab-jupyter:latest` - Jupyter Lab with PySpark
- `mohamedeshmawy/hadoop-spark-lab-airflow:latest` - Apache Airflow

**Pull images:**
```bash
./scripts/pull-images.sh mohamedeshmawy
```

**Or build locally:**
```bash
./scripts/build-images.sh
```

## Useful Commands

```bash
# Pull pre-built images from Docker Hub
./scripts/pull-images.sh mohamedeshmawy

# Build images locally
./scripts/build-images.sh

# Tag images for Docker Hub
./scripts/tag-images.sh mohamedeshmawy

# Push images to Docker Hub (requires Docker Hub account)
./scripts/push-images.sh mohamedeshmawy

# Verify cluster health
./scripts/sanity-check.sh

# Stop the cluster (preserves data)
./scripts/stop-lab.sh

# Complete reset (removes all data)
./scripts/reset-lab.sh

# View logs
docker-compose logs -f namenode
docker-compose logs -f jupyter

# Access container shell
docker exec -it namenode bash
docker exec -it jupyter bash
```

## Troubleshooting

See `docs/TROUBLESHOOTING.md` for detailed solutions to common issues.

**Quick fixes:**
```bash
# Container issues
docker-compose down -v && ./scripts/start-lab.sh

# Port conflicts
docker-compose down
# Then restart Docker Desktop

# Out of memory
# Increase Docker Desktop memory to 8GB+
```

## For Instructors

See `docs/INSTRUCTOR_GUIDE.md` for:
- Learning objectives
- Time estimates
- Teaching tips
- Grading rubric

