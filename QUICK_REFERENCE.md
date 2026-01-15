# Quick Reference Guide

## Starting the Lab

### Option 1: Interactive (Recommended)
```bash
./scripts/start-lab.sh
# Choose: 1 (pull from Docker Hub) or 2 (build locally)
```

### Option 2: Pull Pre-built Images
```bash
./scripts/pull-images.sh
# Uses default debi Docker Hub account
```

### Option 3: Build from Scratch
```bash
./scripts/pull-images.sh --build
# Or: ./scripts/build-images.sh
```

## Stopping the Lab

### Stop with Confirmation
```bash
./scripts/stop-lab.sh
```

### Stop Without Confirmation
```bash
./scripts/stop-lab.sh -f
```

### Stop and Remove All Data
```bash
./scripts/stop-lab.sh -v
# WARNING: Deletes all data volumes!
```

## Docker Hub Workflow

### First Time: Build and Push Images

```bash
# 1. Build images locally
./scripts/build-images.sh

# 2. Tag for Docker Hub
./scripts/tag-images.sh <your-docker-hub-username>

# 3. Login to Docker Hub
docker login

# 4. Push to Docker Hub
./scripts/push-images.sh <your-docker-hub-username>
```

### Subsequent Times: Pull Pre-built Images

```bash
./scripts/pull-images.sh <your-docker-hub-username>
# Or use default: ./scripts/pull-images.sh
```

## Accessing Services

| Service | URL | Token/Password |
|---------|-----|---|
| HDFS NameNode | http://localhost:9870 | - |
| YARN ResourceManager | http://localhost:8088 | - |
| Spark History Server | http://localhost:18080 | - |
| Jupyter Lab | http://localhost:8888 | hadooplab |
| Spark App UI | http://localhost:4040 | - |
| HiveServer2 | localhost:10000 | - |
| Airflow | http://localhost:8080 | - |

## Useful Docker Commands

```bash
# View running containers
docker-compose ps

# View logs
docker-compose logs -f <service>
# Example: docker-compose logs -f jupyter

# Access container shell
docker exec -it <container> bash
# Example: docker exec -it jupyter bash

# View all images
docker images | grep hadoop-spark-lab

# Remove unused images
docker image prune

# Check Docker resources
docker stats
```

## Sanity Checks

```bash
# Run full sanity check
./scripts/sanity-check.sh

# Manual checks
curl http://localhost:9870      # HDFS
curl http://localhost:8088      # YARN
curl http://localhost:18080     # Spark History
curl http://localhost:8888      # Jupyter
```

## Troubleshooting

### Containers won't start
```bash
docker-compose down -v
./scripts/start-lab.sh
```

### Out of memory
- Increase Docker Desktop memory to 8GB+
- Reduce number of NodeManagers in docker-compose.yml

### Port conflicts
```bash
docker-compose down
# Restart Docker Desktop
./scripts/start-lab.sh
```

### View detailed logs
```bash
docker-compose logs -f namenode
docker-compose logs -f jupyter
docker-compose logs -f hiveserver2
```

## GitHub Repository Setup

**Recommended Name:** `hadoop-spark-teaching-lab`

**Full URL:** `https://github.com/augmentcode/hadoop-spark-teaching-lab`

**Topics to Add:**
- hadoop, spark, docker, teaching, big-data, distributed-systems, jupyter, hdfs, yarn, hive

## File Locations

```
hadoop-spark-lab/
├── scripts/
│   ├── start-lab.sh              # Start cluster
│   ├── stop-lab.sh               # Stop cluster
│   ├── build-images.sh           # Build images
│   ├── tag-images.sh             # Tag for Docker Hub
│   ├── push-images.sh            # Push to Docker Hub
│   ├── pull-images.sh            # Pull from Docker Hub
│   └── sanity-check.sh           # Verify cluster health
├── docker/
│   ├── hadoop/                   # Hadoop Dockerfile
│   ├── spark/                    # Spark Dockerfile
│   ├── hive/                     # Hive Dockerfile
│   ├── jupyter/                  # Jupyter Dockerfile
│   └── airflow/                  # Airflow Dockerfile
├── notebooks/                    # Jupyter notebooks
├── exercises/                    # Student exercises
├── data/                         # Sample datasets
├── docs/
│   ├── DOCKER_HUB_SETUP.md      # Docker Hub guide
│   ├── TROUBLESHOOTING.md       # Troubleshooting
│   └── STUDENT_SETUP.md         # Student setup
└── docker-compose.yml            # Cluster definition
```

## Environment Variables

### Jupyter Token
```
JUPYTER_TOKEN=hadooplab
```

### Airflow Fernet Key
```
AIRFLOW__CORE__FERNET_KEY=FB0o_zt4e3Ziq3LdUUO7F2Z95cvFFx16hU8jTeR1ASM=
```

### PostgreSQL
```
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
```

## Common Tasks

### Upload data to HDFS
```bash
docker exec namenode hdfs dfs -put /data/file.csv /user/student/data/
```

### Run Spark job
```bash
docker exec jupyter spark-submit --master yarn --deploy-mode client script.py
```

### Query Hive table
```bash
docker exec hiveserver2 beeline -u jdbc:hive2://localhost:10000 -e "SELECT * FROM table;"
```

### View HDFS contents
```bash
docker exec namenode hdfs dfs -ls /
```

## Performance Tips

1. **Allocate 8GB+ RAM** to Docker Desktop
2. **Use SSD** for better I/O performance
3. **Close unnecessary applications** to free up memory
4. **Pull images from Docker Hub** instead of building (faster)
5. **Use partitioned tables** in Hive for better query performance

## Getting Help

- Check `docs/TROUBLESHOOTING.md` for common issues
- Review `docs/DOCKER_HUB_SETUP.md` for Docker Hub questions
- Check `GITHUB_REPO_RECOMMENDATIONS.md` for naming guidance
- Run `./scripts/sanity-check.sh` to verify cluster health