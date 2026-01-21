#!/bin/bash
# Build the Docker image for PDF generation

set -e

cd "$(dirname "$0")"

echo "Building Docker image..."
docker build -t pdf-generator .
echo "Build complete!"
