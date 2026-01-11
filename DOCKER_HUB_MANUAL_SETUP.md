# Docker Hub Manual Repository Setup

## Step 1: Create Repositories on Docker Hub

You need to create 5 repositories on Docker Hub before pushing images.

### Quick Steps:

1. Go to https://hub.docker.com
2. Sign in with your account (mohamedeshmawy)
3. Click "Create Repository" button (top right)
4. Create these 5 repositories:

#### Repository 1: hadoop-spark-lab-hadoop
- **Name:** hadoop-spark-lab-hadoop
- **Description:** Hadoop HDFS/YARN for teaching lab
- **Visibility:** Public
- Click "Create"

#### Repository 2: hadoop-spark-lab-spark
- **Name:** hadoop-spark-lab-spark
- **Description:** Spark & History Server for teaching lab
- **Visibility:** Public
- Click "Create"

#### Repository 3: hadoop-spark-lab-hive
- **Name:** hadoop-spark-lab-hive
- **Description:** Apache Hive for teaching lab
- **Visibility:** Public
- Click "Create"

#### Repository 4: hadoop-spark-lab-jupyter
- **Name:** hadoop-spark-lab-jupyter
- **Description:** Jupyter Lab with PySpark for teaching lab
- **Visibility:** Public
- Click "Create"

#### Repository 5: hadoop-spark-lab-airflow
- **Name:** hadoop-spark-lab-airflow
- **Description:** Apache Airflow for teaching lab
- **Visibility:** Public
- Click "Create"

## Step 2: Push Images

Once all 5 repositories are created, run:

```bash
./scripts/push-images.sh mohamedeshmawy
```

This will push all 5 images to Docker Hub. Depending on your internet speed, this may take 15-30 minutes.

## Step 3: Verify

Visit your Docker Hub profile to see the uploaded images:
https://hub.docker.com/r/mohamedeshmawy

You should see all 5 repositories with the images.

## Step 4: Update docker-compose.yml (Optional)

If you want to use pre-built images instead of building locally, update `docker-compose.yml`:

Change from:
```yaml
build:
  context: ./docker/hadoop
  dockerfile: Dockerfile
```

To:
```yaml
image: mohamedeshmawy/hadoop-spark-lab-hadoop:latest
```

Do this for all 5 services.

## Troubleshooting

**"denied: requested access to the resource is denied"**
- Make sure all 5 repositories are created on Docker Hub
- Verify you're logged in: `docker login`
- Check the repository names match exactly

**"unauthorized: authentication required"**
- Run `docker login` again
- Enter your Docker Hub username and password

**Push is slow**
- This is normal for large images (2-6GB each)
- Don't interrupt the process
- Total time: 15-30 minutes depending on internet speed

## After Pushing

Users can now pull pre-built images:

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

