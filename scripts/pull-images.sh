#!/bin/bash
# ============================================================
# Hadoop/Spark Teaching Lab - Pre-pull Images for Offline Use
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║     Pre-pulling Docker Images for Offline Use              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${YELLOW}This will download all required base images and build the lab images.${NC}"
echo "Estimated download size: ~3GB"
echo ""

# Pull base images
echo -e "${BLUE}[1/3] Pulling base images...${NC}"
docker pull eclipse-temurin:11-jdk-focal
docker pull jupyter/pyspark-notebook:spark-3.5.0

# Build all images
echo -e "${BLUE}[2/3] Building lab images...${NC}"
docker-compose build

# Save images for export (optional)
echo -e "${BLUE}[3/3] Images are now cached locally.${NC}"

echo ""
echo -e "${GREEN}✓ All images are ready for offline use.${NC}"
echo ""
echo "To export images for transfer to offline machines:"
echo "  docker save -o hadoop-lab-images.tar \\"
echo "    hadoop-namenode hadoop-datanode hadoop-resourcemanager \\"
echo "    hadoop-nodemanager spark-client spark-history jupyter-pyspark"

