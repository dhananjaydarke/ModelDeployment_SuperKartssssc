
#!/bin/bash
set -e


# Clears unused BuildKit cache; this can affect builds for other projects
docker builder prune --all --force

docker pull python:3.9-slim
# Build both images
cd backend
docker build --pull --no-cache -t superkart-backend .
cd ../frontend
docker build --pull --no-cache -t superkart-frontend .

# Create the shared network if it doesn't already exist
docker network inspect backend >/dev/null 2>&1 || docker network create backend

# Remove previous containers only after both images build successfully
docker rm -f superkart-backend superkart-frontend 2>/dev/null || true

# Start the superkart-backend, then the frontend
docker run -d --name superkart-backend --network backend -p 7860:7860 superkart-backend
docker run -d --name superkart-frontend --network backend --add-host=backend:host-gateway -p 8501:8501 superkart-frontend
