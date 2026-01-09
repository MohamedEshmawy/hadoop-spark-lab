# Hadoop/Spark Teaching Lab

A Docker-based environment for learning Hadoop HDFS and Apache Spark. This lab runs entirely on a single PC, simulating a realistic distributed cluster for hands-on learning.

## Quick Start

### Prerequisites
- Docker Desktop installed and running
- 8GB RAM minimum (16GB recommended)
- 20GB free disk space

### One-Command Startup

**Windows (PowerShell):**
```powershell
.\scripts\start-lab.ps1
```

**Mac/Linux (Bash):**
```bash
./scripts/start-lab.sh
```

First startup takes 5-10 minutes to download and build images.

## Web UIs

| Service | URL | Purpose |
|---------|-----|---------|
| HDFS NameNode | http://localhost:9870 | Browse filesystem, DataNode health |
| YARN ResourceManager | http://localhost:8088 | Running applications, node status |
| Spark History Server | http://localhost:18080 | Completed Spark job analysis |
| Jupyter Lab | http://localhost:8888 | Interactive notebooks |
| Spark App UI | http://localhost:4040 | Live Spark job details |

**Jupyter Token:** `hadooplab`

## Cluster Architecture

```
┌──────────────────────────────────────────────────────┐
│              Docker Network                          │
│                                                      │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐       │
│  │ DataNode 1 │ │ DataNode 2 │ │ DataNode 3 │       │
│  └────────────┘ └────────────┘ └────────────┘       │
│         │             │              │               │
│         └─────────────┼──────────────┘               │
│                       ▼                              │
│                ┌────────────┐                        │
│                │  NameNode  │ ← HDFS UI :9870       │
│                └────────────┘                        │
│                                                      │
│  ┌──────────────┐    ┌──────────────┐               │
│  │ NodeManager1 │    │ NodeManager2 │               │
│  └──────────────┘    └──────────────┘               │
│         │                   │                        │
│         └───────────────────┘                        │
│                    ▼                                 │
│           ┌────────────────┐                         │
│           │ResourceManager │ ← YARN UI :8088        │
│           └────────────────┘                         │
│                                                      │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐       │
│  │   Spark    │ │   Spark    │ │  Jupyter   │       │
│  │   Client   │ │  History   │ │    Lab     │       │
│  └────────────┘ └────────────┘ └────────────┘       │
└──────────────────────────────────────────────────────┘
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
│   ├── hadoop/
│   ├── spark/
│   └── jupyter/
├── notebooks/              # Completed example notebooks
├── exercises/              # TODO versions for students
│   └── solutions/          # Answer keys
├── data/                   # Sample datasets
├── scripts/                # Startup and utility scripts
└── docs/                   # Instructor and student guides
```

## Useful Commands

```bash
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

