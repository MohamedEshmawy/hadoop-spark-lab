#!/bin/bash
# ============================================================
# Push Docker Images to Docker Hub
# ============================================================
# Usage: ./scripts/push-images.sh <docker-hub-username>

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <docker-hub-username>"
    echo ""
    echo "Example: $0 myusername"
    exit 1
fi

DOCKER_USERNAME="$1"
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
echo "║     Pushing Images to Docker Hub                          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo "Docker Hub Username: ${DOCKER_USERNAME}"
echo ""

# Check Docker login
echo -e "${YELLOW}Checking Docker Hub login...${NC}"
if ! docker info | grep -q "Username"; then
    echo -e "${YELLOW}Not logged in to Docker Hub. Please login:${NC}"
    docker login
fi
echo -e "${GREEN}✓ Docker Hub login verified${NC}"
echo ""

# Push images
IMAGES=("hadoop" "spark" "hive" "jupyter-airflow")

for image in "${IMAGES[@]}"; do
    echo -e "${YELLOW}Pushing ${DOCKER_USERNAME}/hadoop-spark-lab-${image}:latest...${NC}"
    docker push "${DOCKER_USERNAME}/hadoop-spark-lab-${image}:latest"
    echo -e "${GREEN}✓ Pushed ${DOCKER_USERNAME}/hadoop-spark-lab-${image}:latest${NC}"
    echo ""
done

echo -e "${GREEN}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║           All Images Pushed Successfully!                 ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo "Your images are now available on Docker Hub!"
echo "Repository: https://hub.docker.com/r/${DOCKER_USERNAME}"
echo ""
echo "To use these images, update docker-compose.yml to use:"
echo -e "  ${BLUE}image: ${DOCKER_USERNAME}/hadoop-spark-lab-<service>:latest${NC}"

