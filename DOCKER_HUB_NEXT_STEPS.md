# Docker Hub Push - Next Steps

The Docker images have been built and tagged. Here's what you need to do to push them to Docker Hub.

## Step 1: Create Docker Hub Repositories (Manual)

Visit https://hub.docker.com and create 5 new repositories:

### Repository 1: hadoop-spark-lab-hadoop
- Click "Create Repository"
- Name: `hadoop-spark-lab-hadoop`
- Description: `Hadoop HDFS/YARN for teaching lab`
- Visibility: `Public`
- Click "Create"

### Repository 2: hadoop-spark-lab-spark
- Name: `hadoop-spark-lab-spark`
- Description: `Spark & History Server for teaching lab`
- Visibility: `Public`

### Repository 3: hadoop-spark-lab-hive
- Name: `hadoop-spark-lab-hive`
- Description: `Apache Hive for teaching lab`
- Visibility: `Public`

### Repository 4: hadoop-spark-lab-jupyter
- Name: `hadoop-spark-lab-jupyter`
- Description: `Jupyter Lab with PySpark for teaching lab`
- Visibility: `Public`

### Repository 5: hadoop-spark-lab-airflow
- Name: `hadoop-spark-lab-airflow`
- Description: `Apache Airflow for teaching lab`
- Visibility: `Public`

## Step 2: Push Images to Docker Hub

Once all 5 repositories are created, run:

```bash
cd d:\Work\DEBI\Hadoop
./scripts/push-images.sh mohamedeshmawy
```

**Expected output:**
```
╔════════════════════════════════════════════════════════════╗
║     Pushing Images to Docker Hub                          ║
╚════════════════════════════════════════════════════════════╝

Docker Hub Username: mohamedeshmawy
✓ Docker Hub login verified

Pushing mohamedeshmawy/hadoop-spark-lab-hadoop:latest...
✓ Pushed mohamedeshmawy/hadoop-spark-lab-hadoop:latest
...
```

**Time estimate:** 15-30 minutes (depending on internet speed)

## Step 3: Verify on Docker Hub

Visit: https://hub.docker.com/r/mohamedeshmawy

You should see all 5 repositories with the uploaded images.

## Step 4: Update Documentation (Optional)

Update the README.md to mention:
```markdown
## Quick Start with Pre-built Images

```bash
./scripts/pull-images.sh mohamedeshmawy
./scripts/start-lab.sh
```
```

## Troubleshooting

**"denied: requested access to the resource is denied"**
- Make sure all 5 repositories exist on Docker Hub
- Verify you're logged in: `docker login`

**"unauthorized: authentication required"**
- Run `docker login` and enter credentials
- Or use a personal access token

**Push is slow**
- This is normal for large images (2-6GB each)
- Don't interrupt the process

## After Push

Users can now pull pre-built images:

```bash
./scripts/pull-images.sh mohamedeshmawy
./scripts/start-lab.sh
```

Or manually:

```bash
docker pull mohamedeshmawy/hadoop-spark-lab-hadoop:latest
docker pull mohamedeshmawy/hadoop-spark-lab-spark:latest
docker pull mohamedeshmawy/hadoop-spark-lab-hive:latest
docker pull mohamedeshmawy/hadoop-spark-lab-jupyter:latest
docker pull mohamedeshmawy/hadoop-spark-lab-airflow:latest
```

## Current Status

✅ Images built and tagged
✅ Scripts tested and working
✅ Code pushed to GitHub
⏳ Waiting for Docker Hub repositories to be created
⏳ Ready to push images

**Next action:** Create the 5 repositories on Docker Hub, then run the push script.

