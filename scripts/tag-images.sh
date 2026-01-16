#!/bin/bash
# ============================================================
# Tag Docker Images for Docker Hub
# ============================================================
# Usage: ./scripts/tag-images.sh <docker-hub-username>

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
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║     Tagging Images for Docker Hub                         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo "Docker Hub Username: ${DOCKER_USERNAME}"
echo ""

# Tag images
IMAGES=("hadoop" "spark" "hive" "jupyter-airflow")

for image in "${IMAGES[@]}"; do
    echo -e "${YELLOW}Tagging hadoop-spark-lab/${image}...${NC}"
    docker tag "hadoop-spark-lab/${image}:latest" "${DOCKER_USERNAME}/hadoop-spark-lab-${image}:latest"
    echo -e "${GREEN}✓ Tagged as ${DOCKER_USERNAME}/hadoop-spark-lab-${image}:latest${NC}"
done

echo ""
echo -e "${GREEN}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║           All Images Tagged Successfully!                 ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo "Next: Push to Docker Hub with:"
echo -e "  ${BLUE}./scripts/push-images.sh ${DOCKER_USERNAME}${NC}"

