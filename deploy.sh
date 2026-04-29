#!/bin/bash

set -e

echo "🚀 Starting rolling deployment..."

TAG=$(git rev-parse --short HEAD)

echo "Deploying version: $TAG"

# Step 1: Build new image
docker build -t localhost:5000/api:$TAG ./api

# Step 2: Stop previous temp container (if exists)
docker stop api_new || true
docker rm api_new || true

# Step 3: Start new container
docker run -d \
  --name api_new \
  -p 8000:8000 \
  localhost:5000/api:$TAG

# Step 4: Health check loop
TIMEOUT=60
INTERVAL=5
ELAPSED=0

echo "⏳ Waiting for API health..."

until curl -f http://localhost:8000/health; do
  sleep $INTERVAL
  ELAPSED=$((ELAPSED + INTERVAL))

  if [ $ELAPSED -ge $TIMEOUT ]; then
    echo "❌ Health check failed - rolling back"

    docker stop api_new || true
    docker rm api_new || true

    exit 1
  fi
done

echo "✅ New version is healthy"

# Step 5: Replace old container
docker stop api_old || true
docker rm api_old || true

docker rename api_new api_old

echo "🎉 Rolling deployment complete"
