#!/bin/bash
# ============================================================
# Hadoop/Spark Teaching Lab - Pull/Build Docker Images
# ============================================================
# Usage: ./scripts/pull-images.sh [--build]
#
# Options:
#   --build              Build images from scratch instead of pulling
#   -h, --help           Show this help message

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

# Parse arguments
BUILD_FROM_SCRATCH=false
DOCKER_HUB_USER="bleadfast"

while [[ $# -gt 0 ]]; do
    case $1 in
        --build)
            BUILD_FROM_SCRATCH=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --build                Build images from scratch instead of pulling"
            echo "  -h, --help             Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                     Pull pre-built images from Docker Hub"
            echo "  $0 --build             Build images locally from scratch"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
if [ "$BUILD_FROM_SCRATCH" = true ]; then
    echo "║     Building Docker Images from Scratch                   ║"
else
    echo "║     Pulling Pre-built Docker Images from Docker Hub       ║"
fi
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

if [ "$BUILD_FROM_SCRATCH" = true ]; then
    # Build from scratch
    echo -e "${YELLOW}Building all images from scratch...${NC}"
    docker-compose build --quiet
    echo -e "${GREEN}✓ All images built successfully${NC}"
else
    # Pull from Docker Hub
    echo -e "${YELLOW}Pulling images from Docker Hub (user: ${DOCKER_HUB_USER})...${NC}"
    IMAGES=("hadoop" "spark" "hive" "jupyter" "airflow")

    for image in "${IMAGES[@]}"; do
        echo -e "${YELLOW}  Pulling ${DOCKER_HUB_USER}/hadoop-spark-lab-${image}:latest...${NC}"
        docker pull "${DOCKER_HUB_USER}/hadoop-spark-lab-${image}:latest"
        docker tag "${DOCKER_HUB_USER}/hadoop-spark-lab-${image}:latest" "hadoop-spark-lab/${image}:latest"
        echo -e "${GREEN}  ✓ Pulled and tagged${NC}"
    done
    echo -e "${GREEN}✓ All images pulled successfully${NC}"
fi

echo ""
echo -e "${GREEN}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║           Images Ready!                                    ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo "Next: Start the lab with:"
echo -e "  ${BLUE}./scripts/start-lab.sh${NC}"

