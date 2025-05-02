#!/usr/bin/env bash
set -euo pipefail

DOCKERFILE="Dockerfile"
IMAGE_NAME="astra-sim:latest"

# Build context
BUILD_CONTEXT="../"

echo "Building Docker image '${IMAGE_NAME}' from '${DOCKERFILE}'..."

docker build \
  -f "${DOCKERFILE}" \
  -t "${IMAGE_NAME}" \
  "${BUILD_CONTEXT}"

echo "✅ Build complete! Image '${IMAGE_NAME}' is ready."

# sudo docker run -it -v $(pwd):/app/astra-sim astra-sim:latest
# sudo docker run -it astra-sim:latest