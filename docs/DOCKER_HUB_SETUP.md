# Docker Hub Setup Guide

This guide explains how to build, tag, and push the Hadoop/Spark Teaching Lab images to Docker Hub.

## Prerequisites

1. **Docker Desktop** installed and running
2. **Docker Hub account** (free at https://hub.docker.com)
3. **Docker CLI logged in** to your Docker Hub account

## Step 1: Create Docker Hub Repository

1. Go to https://hub.docker.com
2. Sign in or create a free account
3. Click "Create Repository"
4. Create 5 repositories (one for each image):
   - `hadoop-spark-lab-hadoop`
   - `hadoop-spark-lab-spark`
   - `hadoop-spark-lab-hive`
   - `hadoop-spark-lab-jupyter`
   - `hadoop-spark-lab-airflow`

## Step 2: Build Images Locally

Build all custom Docker images from scratch:

```bash
./scripts/build-images.sh
```

This creates local images tagged as:
- `hadoop-spark-lab/hadoop:latest`
- `hadoop-spark-lab/spark:latest`
- `hadoop-spark-lab/hive:latest`
- `hadoop-spark-lab/jupyter:latest`
- `hadoop-spark-lab/airflow:latest`

## Step 3: Tag Images for Docker Hub

Tag the images with your Docker Hub username:

```bash
./scripts/tag-images.sh <your-docker-hub-username>
```

Example:
```bash
./scripts/tag-images.sh johndoe
```

This creates tags like:
- `johndoe/hadoop-spark-lab-hadoop:latest`
- `johndoe/hadoop-spark-lab-spark:latest`
- etc.

## Step 4: Login to Docker Hub

```bash
docker login
```

Enter your Docker Hub username and password when prompted.

## Step 5: Push Images to Docker Hub

Push all tagged images to Docker Hub:

```bash
./scripts/push-images.sh <your-docker-hub-username>
```

Example:
```bash
./scripts/push-images.sh johndoe
```

This uploads all images to your Docker Hub repositories. Depending on your internet speed, this may take 10-30 minutes.

## Step 6: Verify Images on Docker Hub

Visit https://hub.docker.com/r/yourusername to see your uploaded images.

## Using Pre-built Images

Once images are on Docker Hub, users can pull them instead of building:

```bash
./scripts/pull-images.sh <your-docker-hub-username>
```

Or use the default (if you're the maintainer):

```bash
./scripts/pull-images.sh
```

## Updating Images

When you make changes to the Dockerfiles:

1. Rebuild: `./scripts/build-images.sh`
2. Tag: `./scripts/tag-images.sh <username>`
3. Push: `./scripts/push-images.sh <username>`

## Making Images Public

By default, repositories are private. To make them public:

1. Go to https://hub.docker.com/r/yourusername
2. Click on each repository
3. Go to Settings → Visibility
4. Change to "Public"

This allows anyone to pull your images without authentication.

## Troubleshooting

**"unauthorized: authentication required"**
- Run `docker login` and enter your credentials

**"denied: requested access to the resource is denied"**
- Make sure the repository exists on Docker Hub
- Check that you're using the correct username

**"image not found"**
- Verify the image was built: `docker images | grep hadoop-spark-lab`
- Check the tag is correct

## For Official Maintainers

If maintaining the official `augmentcode` repository:

```bash
./scripts/build-images.sh
./scripts/tag-images.sh augmentcode
./scripts/push-images.sh augmentcode
```

Users can then simply run:
```bash
./scripts/pull-images.sh
```

To get the official pre-built images.

