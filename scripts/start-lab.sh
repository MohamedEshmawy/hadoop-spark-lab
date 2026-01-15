#!/bin/bash
# ============================================================
# Hadoop/Spark Teaching Lab - One-Command Startup Script
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║     Hadoop/Spark Teaching Lab - Starting Cluster          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check Docker is running
echo -e "${YELLOW}[1/5] Checking Docker...${NC}"
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not running. Please start Docker Desktop.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker is running${NC}"

# Check available resources
echo -e "${YELLOW}[2/5] Checking system resources...${NC}"
DOCKER_MEM=$(docker info --format '{{.MemTotal}}' 2>/dev/null || echo "0")
DOCKER_MEM_GB=$((DOCKER_MEM / 1024 / 1024 / 1024))
if [ "$DOCKER_MEM_GB" -lt 6 ]; then
    echo -e "${YELLOW}Warning: Docker has ${DOCKER_MEM_GB}GB RAM. Recommend at least 8GB for best performance.${NC}"
else
    echo -e "${GREEN}✓ Docker has ${DOCKER_MEM_GB}GB RAM available${NC}"
fi

# Pull or build images
echo -e "${YELLOW}[3/5] Preparing Docker images...${NC}"
echo "  Options:"
echo "    1) Pull pre-built images from Docker Hub (faster, ~2-3 min)"
echo "    2) Build images from scratch (slower, ~10-15 min)"
echo ""
read -p "  Choose option (1 or 2) [default: 1]: " -r image_option
image_option=${image_option:-1}

if [ "$image_option" = "2" ]; then
    echo -e "${YELLOW}Building images from scratch...${NC}"
    docker-compose build --quiet
else
    echo -e "${YELLOW}Pulling pre-built images from Docker Hub...${NC}"
    ./scripts/pull-images.sh
fi

# Start the cluster
echo -e "${YELLOW}[4/5] Starting cluster services...${NC}"
docker-compose up -d

# Wait for services to be healthy
echo -e "${YELLOW}[5/5] Waiting for services to be ready...${NC}"
echo "This may take 1-2 minutes on first startup..."

# Wait for NameNode
echo -n "  Waiting for NameNode..."
for i in {1..60}; do
    if curl -s http://localhost:9870 > /dev/null 2>&1; then
        echo -e " ${GREEN}✓${NC}"
        break
    fi
    sleep 2
    echo -n "."
done

# Wait for ResourceManager
echo -n "  Waiting for ResourceManager..."
for i in {1..60}; do
    if curl -s http://localhost:8088 > /dev/null 2>&1; then
        echo -e " ${GREEN}✓${NC}"
        break
    fi
    sleep 2
    echo -n "."
done

# Wait for Jupyter
echo -n "  Waiting for Jupyter Lab..."
for i in {1..30}; do
    if curl -s http://localhost:8888 > /dev/null 2>&1; then
        echo -e " ${GREEN}✓${NC}"
        break
    fi
    sleep 2
    echo -n "."
done

echo ""
echo -e "${GREEN}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║           Cluster is Ready!                                ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo "Access the following UIs:"
echo -e "  ${BLUE}HDFS NameNode:${NC}        http://localhost:9870"
echo -e "  ${BLUE}YARN ResourceManager:${NC} http://localhost:8088"
echo -e "  ${BLUE}Spark History Server:${NC} http://localhost:18080"
echo -e "  ${BLUE}Jupyter Lab:${NC}          http://localhost:8888 (token: hadooplab)"
echo ""
echo "To run sanity checks: ./scripts/sanity-check.sh"
echo "To stop the cluster:  ./scripts/stop-lab.sh"
echo ""

