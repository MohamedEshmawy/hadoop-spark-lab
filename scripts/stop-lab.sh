#!/bin/bash
# ============================================================
# Hadoop/Spark Teaching Lab - Stop Script
# ============================================================

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
REMOVE_VOLUMES=false
FORCE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--volumes)
            REMOVE_VOLUMES=true
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -v, --volumes    Remove all data volumes (WARNING: deletes all data)"
            echo "  -f, --force      Skip confirmation prompt"
            echo "  -h, --help       Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║     Hadoop/Spark Teaching Lab - Stopping Cluster          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Confirmation prompt
if [ "$FORCE" = false ]; then
    if [ "$REMOVE_VOLUMES" = true ]; then
        echo -e "${YELLOW}WARNING: This will remove all data volumes!${NC}"
        echo "All data will be permanently deleted."
        read -p "Are you sure? (yes/no): " -r
        if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
            echo -e "${YELLOW}Cancelled.${NC}"
            exit 0
        fi
    else
        read -p "Stop the cluster? (yes/no): " -r
        if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
            echo -e "${YELLOW}Cancelled.${NC}"
            exit 0
        fi
    fi
fi

# Stop containers
echo -e "${YELLOW}Stopping containers...${NC}"
if [ "$REMOVE_VOLUMES" = true ]; then
    docker-compose down -v
    echo -e "${GREEN}✓ Cluster stopped and all volumes removed${NC}"
else
    docker-compose down
    echo -e "${GREEN}✓ Cluster stopped successfully${NC}"
fi

echo ""
if [ "$REMOVE_VOLUMES" = false ]; then
    echo "Note: Data volumes are preserved."
    echo "To remove all data and start fresh, run:"
    echo -e "  ${BLUE}./scripts/stop-lab.sh --volumes${NC}"
else
    echo "All data volumes have been removed."
fi

