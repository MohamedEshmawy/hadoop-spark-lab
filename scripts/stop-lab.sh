#!/bin/bash
# ============================================================
# Hadoop/Spark Teaching Lab - Stop Script
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Stopping Hadoop/Spark Teaching Lab...${NC}"

docker-compose down

echo -e "${GREEN}✓ Cluster stopped successfully${NC}"
echo ""
echo "Note: Data volumes are preserved. To remove all data, run:"
echo "  docker-compose down -v"

