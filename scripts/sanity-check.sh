#!/bin/bash
# ============================================================
# Hadoop/Spark Teaching Lab - Sanity Check Script
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

PASSED=0
FAILED=0

check() {
    local name="$1"
    local cmd="$2"
    echo -n "  Checking $name... "
    if eval "$cmd" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((PASSED++))
    else
        echo -e "${RED}✗ FAIL${NC}"
        ((FAILED++))
    fi
}

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║           Hadoop/Spark Lab - Sanity Checks                 ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${YELLOW}[Container Status]${NC}"
check "NameNode container" "docker ps | grep -q namenode"
check "DataNode1 container" "docker ps | grep -q datanode1"
check "DataNode2 container" "docker ps | grep -q datanode2"
check "DataNode3 container" "docker ps | grep -q datanode3"
check "ResourceManager container" "docker ps | grep -q resourcemanager"
check "NodeManager1 container" "docker ps | grep -q nodemanager1"
check "NodeManager2 container" "docker ps | grep -q nodemanager2"
check "Jupyter container" "docker ps | grep -q jupyter"

echo ""
echo -e "${YELLOW}[Web UIs]${NC}"
check "HDFS NameNode UI (9870)" "curl -s http://localhost:9870 | grep -q 'NameNode'"
check "YARN ResourceManager UI (8088)" "curl -s http://localhost:8088 | grep -q 'ResourceManager'"
check "Spark History Server UI (18080)" "curl -s http://localhost:18080 | grep -qi 'spark'"
check "Jupyter Lab UI (8888)" "curl -s http://localhost:8888 | grep -qi 'jupyter'"

echo ""
echo -e "${YELLOW}[HDFS Cluster Health]${NC}"
check "HDFS Safe Mode off" "docker exec namenode hdfs dfsadmin -safemode get 2>/dev/null | grep -q 'OFF'"
check "All DataNodes live" "docker exec namenode hdfs dfsadmin -report 2>/dev/null | grep -q 'Live datanodes (3)'"
check "HDFS file operations" "docker exec namenode bash -c 'echo test | hdfs dfs -put - /test_sanity.txt && hdfs dfs -rm /test_sanity.txt' 2>/dev/null"

echo ""
echo -e "${YELLOW}[YARN Cluster Health]${NC}"
check "YARN nodes active" "docker exec resourcemanager yarn node -list 2>/dev/null | grep -q 'RUNNING'"

echo ""
echo -e "${YELLOW}[Spark Connectivity]${NC}"
check "Spark client ready" "docker exec spark-client spark-submit --version 2>/dev/null"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}"
echo "═══════════════════════════════════════════════════════════════"

if [ $FAILED -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}Some checks failed. Try:${NC}"
    echo "  1. Wait a few more seconds for services to start"
    echo "  2. Run: docker-compose logs [service-name]"
    echo "  3. Check troubleshooting guide in docs/TROUBLESHOOTING.md"
    exit 1
fi

echo ""
echo -e "${GREEN}All checks passed! The lab is ready for use.${NC}"

