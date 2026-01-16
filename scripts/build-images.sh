#!/bin/bash
# ============================================================
# Build Docker Images for Hadoop/Spark Teaching Lab
# ============================================================
# This script builds all custom Docker images locally.
# Use this if you want to rebuild from scratch instead of
# pulling pre-built images from Docker Hub.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║     Building Docker Images from Scratch                   ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check Docker is running
echo -e "${YELLOW}Checking Docker...${NC}"
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not running. Please start Docker Desktop.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker is running${NC}"
echo ""

# Build images
IMAGES=(
    "hadoop:Hadoop HDFS/YARN"
    "spark:Spark & History Server"
    "hive:Apache Hive"
    "jupyter-airflow:Jupyter Lab + Apache Airflow"
)

for image_info in "${IMAGES[@]}"; do
    IFS=':' read -r image_dir image_name <<< "$image_info"
    echo -e "${YELLOW}Building ${image_name}...${NC}"
    docker build -t "hadoop-spark-lab/${image_dir}:latest" "./docker/${image_dir}" --quiet
    echo -e "${GREEN}✓ Built hadoop-spark-lab/${image_dir}:latest${NC}"
done

echo ""
echo -e "${GREEN}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║           All Images Built Successfully!                  ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo "Next steps:"
echo "  1. Tag images for Docker Hub: ./scripts/tag-images.sh <username>"
echo "  2. Push to Docker Hub:        ./scripts/push-images.sh <username>"
echo "  3. Start the lab:             ./scripts/start-lab.sh"

