#!/bin/bash
echo "Stopping Edge AI Retail System..."
docker-compose down
echo "All services stopped."
echo ""
echo "To remove all data: docker-compose down -v"
