#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================="
echo "Edge AI Retail - Full System Verification"
echo "========================================="
echo ""

passed=0
failed=0

# Test 1: Docker services
echo "TEST 1: Checking Docker services..."
services=$(docker compose ps --services --filter "status=running" | wc -l)
expected=8  # Total services in docker-compose

if [ "$services" -eq "$expected" ]; then
    echo -e "${GREEN}✅ PASS${NC} - All $services services are running"
    ((passed++))
else
    echo -e "${RED}❌ FAIL${NC} - Only $services/$expected services running"
    echo "Run: docker-compose ps"
    ((failed++))
fi
echo ""

# Test 2: Cloud Server health
echo "TEST 2: Checking Cloud Server health..."
health=$(curl -s http://localhost:8000/health)
if echo "$health" | grep -q "healthy"; then
    echo -e "${GREEN}✅ PASS${NC} - Cloud Server is healthy"
    ((passed++))
else
    echo -e "${RED}❌ FAIL${NC} - Cloud Server health check failed"
    echo "Response: $health"
    ((failed++))
fi
echo ""

# Test 3: MQTT connectivity
echo "TEST 3: Checking MQTT broker..."
mqtt_test=$(timeout 3s docker exec mqtt-broker mosquitto_sub -t "test" -C 1 2>&1)
if [ $? -eq 124 ] || [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ PASS${NC} - MQTT broker is accessible"
    ((passed++))
else
    echo -e "${RED}❌ FAIL${NC} - Cannot connect to MQTT broker"
    ((failed++))
fi
echo ""

# Test 4: Database connectivity
echo "TEST 4: Checking PostgreSQL database..."
db_test=$(docker exec postgres-db psql -U admin -d retail_db -c "SELECT 1;" 2>&1)
if echo "$db_test" | grep -q "1 row"; then
    echo -e "${GREEN}✅ PASS${NC} - Database is accessible"
    ((passed++))
else
    echo -e "${RED}❌ FAIL${NC} - Database connection failed"
    ((failed++))
fi
echo ""

# Test 5: Edge devices producing data
echo "TEST 5: Checking if Edge devices are producing data..."
echo "   Waiting 15 seconds for data accumulation..."
sleep 15

txn_count=$(curl -s "http://localhost:8000/api/v1/transactions?limit=1" | grep -o "transaction_id" | wc -l)
if [ "$txn_count" -gt 0 ]; then
    echo -e "${GREEN}✅ PASS${NC} - Edge devices are producing transactions"
    ((passed++))
else
    echo -e "${YELLOW}⚠️  WARN${NC} - No transactions found yet (might need more time)"
    echo "   Wait 1-2 minutes and check: curl http://localhost:8000/api/v1/transactions"
    ((failed++))
fi
echo ""

# Test 6: Both branches active
echo "TEST 6: Checking if both branches are active..."
branches=$(curl -s "http://localhost:8000/api/v1/branches")
branch1=$(echo "$branches" | grep -o "branch_001" | wc -l)
branch2=$(echo "$branches" | grep -o "branch_002" | wc -l)

if [ "$branch1" -gt 0 ] && [ "$branch2" -gt 0 ]; then
    echo -e "${GREEN}✅ PASS${NC} - Both branches (branch_001, branch_002) are active"
    ((passed++))
else
    echo -e "${YELLOW}⚠️  WARN${NC} - Not all branches detected yet"
    echo "   Branches: $branches"
fi
echo ""

# Test 7: Prometheus metrics
echo "TEST 7: Checking Prometheus metrics..."
prom_status=$(curl -s http://localhost:9090/-/healthy)
if echo "$prom_status" | grep -q "Prometheus"; then
    echo -e "${GREEN}✅ PASS${NC} - Prometheus is running"
    ((passed++))
else
    echo -e "${RED}❌ FAIL${NC} - Prometheus is not accessible"
    ((failed++))
fi
echo ""

# Test 8: Grafana
echo "TEST 8: Checking Grafana..."
grafana_status=$(curl -s http://localhost:3000/api/health)
if echo "$grafana_status" | grep -q "ok"; then
    echo -e "${GREEN}✅ PASS${NC} - Grafana is running"
    ((passed++))
else
    echo -e "${RED}❌ FAIL${NC} - Grafana is not accessible"
    ((failed++))
fi
echo ""

# Summary
echo "========================================="
echo "VERIFICATION SUMMARY"
echo "========================================="
echo -e "Tests Passed: ${GREEN}$passed${NC}"
echo -e "Tests Failed: ${RED}$failed${NC}"
echo ""

if [ "$failed" -eq 0 ] && [ "$passed" -ge 6 ]; then
    echo -e "${GREEN}🎉 SUCCESS!${NC} Your Edge Device simulation is working correctly!"
    echo ""
    echo "Next steps:"
    echo "  1. View live logs: docker-compose logs -f edge-device-1"
    echo "  2. Monitor transactions: curl http://localhost:8000/api/v1/transactions"
    echo "  3. Check Grafana: http://localhost:3000 (admin/admin)"
    echo "  4. API docs: http://localhost:8000/docs"
    exit 0
elif [ "$passed" -ge 4 ]; then
    echo -e "${YELLOW}⚠️  PARTIAL SUCCESS${NC} - System is running but needs more time"
    echo ""
    echo "Wait 2-3 minutes for data to accumulate, then re-run this script"
    echo "Or check logs: docker-compose logs -f"
    exit 1
else
    echo -e "${RED}❌ SYSTEM FAILURE${NC} - Multiple components are not working"
    echo ""
    echo "Troubleshooting steps:"
    echo "  1. Check logs: docker-compose logs"
    echo "  2. Restart system: docker-compose restart"
    echo "  3. Rebuild: docker-compose up -d --build"
    exit 2
fi
