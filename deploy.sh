#!/bin/bash

set -e

echo "🚀 Starting rolling deployment..."

# Step 1: Pull latest code/build
docker compose build

# Step 2: Start new version WITHOUT stopping old one yet
docker compose up -d

# Step 3: Wait for health check (60 seconds max)
TIMEOUT=60
INTERVAL=5
ELAPSED=0

echo "⏳ Waiting for API health..."

until curl -f http://localhost:8000/health; do
  sleep $INTERVAL
  ELAPSED=$((ELAPSED + INTERVAL))

  if [ $ELAPSED -ge $TIMEOUT ]; then
    echo "❌ Health check failed - rolling back"

    docker compose down
    exit 1
  fi
done

echo "✅ New version is healthy"

# Step 4: Now safely stop old containers
docker compose down

# Step 5: Start clean stable version
docker compose up -d

echo "🎉 Rolling deployment complete"
