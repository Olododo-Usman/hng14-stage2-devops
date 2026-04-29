#!/bin/bash

set -e

TAG=$(git rev-parse --short HEAD)

echo "Deploying version $TAG"

docker pull localhost:5000/api:$TAG || true

docker stop api_old || true
docker rm api_old || true

docker rename api api_old || true

docker run -d \
  --name api \
  -p 8000:8000 \
  localhost:5000/api:$TAG

echo "Waiting for health check..."

for i in {1..30}; do
  if curl -f http://localhost:8000/health; then
    echo "Deployment successful"
    exit 0
  fi
  sleep 2
done

echo "Deployment failed"
exit 1
