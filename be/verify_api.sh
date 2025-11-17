#!/bin/bash

echo "API"


# Test 1: Health check
echo "1. Testing health endpoint..."
response=$(curl -s http://localhost:8000/health)
if echo "$response" | grep -q "healthy"; then
    echo "   Health check PASSED"
else
    echo "   Health check FAILED"
    echo "   Response: $response"
fi
echo ""

# Wait a bit for data to accumulate
echo "Waiting 10 seconds for data to accumulate..."
sleep 10

# Test 2: Get transactions
echo "2. Testing transactions endpoint..."
transactions=$(curl -s http://localhost:8000/api/v1/transactions?limit=5)
count=$(echo "$transactions" | grep -o "transaction_id" | wc -l)
if [ "$count" -gt 0 ]; then
    echo "   Transactions endpoint PASSED ($count transactions found)"
    echo "   Sample: $(echo "$transactions" | head -c 200)..."
else
    echo "   Transactions endpoint FAILED (no data)"
    echo "   Response: $transactions"
fi
echo ""

# Test 3: Get branches
echo "3. Testing branches endpoint..."
branches=$(curl -s http://localhost:8000/api/v1/branches)
if echo "$branches" | grep -q "branch_001"; then
    echo "   Branches endpoint PASSED"
    echo "   Branches: $branches"
else
    echo "   Branches endpoint FAILED"
    echo "   Response: $branches"
fi
echo ""

# Test 4: Get branch stats
echo "4. Testing branch stats endpoint..."
stats=$(curl -s "http://localhost:8000/api/v1/branches/branch_001/stats?days=1")
if echo "$stats" | grep -q "total_transactions"; then
    echo "  Branch stats endpoint PASSED"
    echo "   Stats: $stats"
else
    echo "   Branch stats endpoint returned but might have no data yet"
    echo "   Response: $stats"
fi
echo ""

# Test 5: Get metrics summary
echo "5. Testing metrics summary endpoint..."
metrics=$(curl -s http://localhost:8000/api/v1/metrics/summary)
if echo "$metrics" | grep -q "total_transactions"; then
    echo "   metrics summary endpoint PASSED"
    echo "   Metrics: $metrics"
else
    echo "   Metrics endpoint returned but might have no data yet"
fi
echo ""



