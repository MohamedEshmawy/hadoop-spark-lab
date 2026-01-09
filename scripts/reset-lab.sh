#!/bin/bash
# ============================================================
# Hadoop/Spark Teaching Lab - Complete Reset Script
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${YELLOW}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║           WARNING: Complete Lab Reset                       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo "This will:"
echo "  - Stop all containers"
echo "  - Remove all HDFS data"
echo "  - Remove all Spark logs"
echo "  - Remove all volumes"
echo ""
read -p "Are you sure you want to reset? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Reset cancelled."
    exit 0
fi

echo -e "${BLUE}[1/3] Stopping containers...${NC}"
docker-compose down -v --remove-orphans

echo -e "${BLUE}[2/3] Removing orphan volumes...${NC}"
docker volume prune -f 2>/dev/null || true

echo -e "${BLUE}[3/3] Cleaning up...${NC}"
# Remove any leftover data
rm -rf "$PROJECT_DIR/data/output" 2>/dev/null || true

echo ""
echo -e "${GREEN}✓ Lab has been completely reset${NC}"
echo ""
echo "To start fresh, run: ./scripts/start-lab.sh"

