# Making Docker Hub Images Public

Your Docker Hub images are currently **private**, which is why students get "access denied" errors when trying to pull them.

## Step 1: Make Images Public on Docker Hub

For each of the 5 repositories, you need to change the visibility to **Public**:

1. Go to https://hub.docker.com/r/mohamedeshmawy
2. Click on each repository:
   - `hadoop-spark-lab-hadoop`
   - `hadoop-spark-lab-spark`
   - `hadoop-spark-lab-hive`
   - `hadoop-spark-lab-jupyter`
   - `hadoop-spark-lab-airflow`

3. For each repository:
   - Click **Settings** (gear icon)
   - Scroll to **Repository Visibility**
   - Change from **Private** to **Public**
   - Click **Save**

## Step 2: Verify Images are Public

Visit: https://hub.docker.com/r/mohamedeshmawy

You should see all 5 repositories listed as **Public**.

## Step 3: Test Pull (No Login Required)

Students can now pull without logging in:

```bash
./scripts/pull-images.sh
./scripts/start-lab.sh
```

## Troubleshooting

**Still getting "access denied"?**
- Wait 5-10 minutes for Docker Hub to update
- Try: `docker logout` then `docker pull mohamedeshmawy/hadoop-spark-lab-hadoop:latest`
- Verify the repository is actually public on Docker Hub

**Images not found?**
- Make sure you pushed all 5 images: `./scripts/push-images.sh mohamedeshmawy`
- Check they exist at: https://hub.docker.com/r/mohamedeshmawy

## Why This Matters

- **Private images**: Only you can pull (requires login)
- **Public images**: Anyone can pull (no login needed)

For a teaching lab, public images are essential so students can get started immediately!

