#!/bin/bash
# ============================================================
# Upload sample data to HDFS
# Run this after the cluster is started
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Uploading sample data to HDFS...${NC}"

# Wait for HDFS to be ready
echo "Waiting for HDFS..."
while ! docker exec namenode hdfs dfs -ls / > /dev/null 2>&1; do
    sleep 2
done

# Create directories
echo "Creating HDFS directories..."
docker exec namenode hdfs dfs -mkdir -p /user/student/data
docker exec namenode hdfs dfs -mkdir -p /user/student/output

# Upload data
echo "Uploading transactions.csv..."
docker exec namenode hdfs dfs -put -f /data/sales/transactions.csv /user/student/data/

echo "Uploading products..."
docker exec namenode hdfs dfs -put -f /data/products/catalog.csv /user/student/data/
docker exec namenode hdfs dfs -put -f /data/products/catalog.json /user/student/data/

echo "Uploading customers..."
docker exec namenode hdfs dfs -put -f /data/customers/customers.csv /user/student/data/

# Verify
echo ""
echo -e "${YELLOW}Uploaded files:${NC}"
docker exec namenode hdfs dfs -ls -h /user/student/data/

echo ""
echo -e "${GREEN}✓ Data upload complete!${NC}"

