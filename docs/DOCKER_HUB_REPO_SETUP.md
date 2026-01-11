# Docker Hub Repository Setup

Before pushing images to Docker Hub, you need to create the repositories.

## Step 1: Create Repositories on Docker Hub

Visit https://hub.docker.com and create 5 new repositories:

1. **hadoop-spark-lab-hadoop**
   - Description: Hadoop HDFS/YARN for teaching lab
   - Visibility: Public (optional, can be private)

2. **hadoop-spark-lab-spark**
   - Description: Spark & History Server for teaching lab
   - Visibility: Public

3. **hadoop-spark-lab-hive**
   - Description: Apache Hive for teaching lab
   - Visibility: Public

4. **hadoop-spark-lab-jupyter**
   - Description: Jupyter Lab with PySpark for teaching lab
   - Visibility: Public

5. **hadoop-spark-lab-airflow**
   - Description: Apache Airflow for teaching lab
   - Visibility: Public

## Step 2: Push Images

Once repositories are created, push the images:

```bash
./scripts/push-images.sh mohamedeshmawy
```

## Step 3: Verify on Docker Hub

Visit your Docker Hub profile to see the uploaded images:
https://hub.docker.com/r/mohamedeshmawy

## Making Repositories Public

If you want others to pull without authentication:

1. Go to each repository on Docker Hub
2. Click "Settings"
3. Change "Visibility" to "Public"
4. Save

## Troubleshooting

**"denied: requested access to the resource is denied"**
- The repository doesn't exist on Docker Hub
- Create it manually at https://hub.docker.com
- Make sure you're logged in: `docker login`

**"unauthorized: authentication required"**
- Run `docker login` and enter your credentials
- Or use a personal access token instead of password

## Using Pre-built Images

Once pushed, users can pull with:

```bash
./scripts/pull-images.sh mohamedeshmawy
```

Or manually:

```bash
docker pull mohamedeshmawy/hadoop-spark-lab-hadoop:latest
docker pull mohamedeshmawy/hadoop-spark-lab-spark:latest
docker pull mohamedeshmawy/hadoop-spark-lab-hive:latest
docker pull mohamedeshmawy/hadoop-spark-lab-jupyter:latest
docker pull mohamedeshmawy/hadoop-spark-lab-airflow:latest
```

