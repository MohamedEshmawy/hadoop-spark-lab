#!/bin/bash
# ============================================================
# Create Docker Hub Repositories
# ============================================================
# This script creates the required repositories on Docker Hub
# using the Docker Hub API.
#
# Usage: ./scripts/create-docker-hub-repos.sh <username> <password>

set -e

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <docker-hub-username> <docker-hub-password>"
    echo ""
    echo "This script creates 5 repositories on Docker Hub:"
    echo "  - hadoop-spark-lab-hadoop"
    echo "  - hadoop-spark-lab-spark"
    echo "  - hadoop-spark-lab-hive"
    echo "  - hadoop-spark-lab-jupyter"
    echo "  - hadoop-spark-lab-airflow"
    echo ""
    echo "Note: Use a personal access token instead of password for security"
    echo "Create one at: https://hub.docker.com/settings/security"
    exit 1
fi

USERNAME="$1"
PASSWORD="$2"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║     Creating Docker Hub Repositories                       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Get Docker Hub token
echo -e "${YELLOW}Authenticating with Docker Hub...${NC}"
TOKEN=$(curl -s -H "Content-Type: application/json" \
  -X POST \
  -d "{\"username\": \"$USERNAME\", \"password\": \"$PASSWORD\"}" \
  https://hub.docker.com/v2/users/login | grep -o '"token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    echo -e "${RED}Error: Failed to authenticate with Docker Hub${NC}"
    echo "Check your username and password/token"
    exit 1
fi

echo -e "${GREEN}✓ Authenticated${NC}"

# Create repositories
REPOS=("hadoop" "spark" "hive" "jupyter" "airflow")

for repo in "${REPOS[@]}"; do
    REPO_NAME="hadoop-spark-lab-${repo}"
    echo -e "${YELLOW}Creating repository: ${REPO_NAME}...${NC}"
    
    RESPONSE=$(curl -s -H "Authorization: JWT ${TOKEN}" \
      -H "Content-Type: application/json" \
      -X POST \
      -d "{\"name\": \"${REPO_NAME}\", \"description\": \"${repo^} for Hadoop/Spark Teaching Lab\", \"is_private\": false}" \
      https://hub.docker.com/v2/repositories/${USERNAME}/)
    
    if echo "$RESPONSE" | grep -q "\"name\""; then
        echo -e "${GREEN}✓ Created ${REPO_NAME}${NC}"
    else
        # Repository might already exist
        echo -e "${YELLOW}⚠ ${REPO_NAME} (may already exist)${NC}"
    fi
done

echo ""
echo -e "${GREEN}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║           Repositories Ready!                              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo "Next: Push images with:"
echo -e "  ${BLUE}./scripts/push-images.sh ${USERNAME}${NC}"

