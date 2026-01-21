#!/bin/bash
# Run PDF generation in Docker container
# Usage: ./convert.sh [all]
#   all - Regenerate all PDFs, not just modified ones

set -e

cd "$(dirname "$0")/.."
SCRIPTS_DIR="$(dirname "$0")"

# Check if image exists
if ! docker image inspect pdf-generator >/dev/null 2>&1; then
    echo "Docker image not found. Building..."
    "$SCRIPTS_DIR/build.sh"
fi

# Check if 'all' parameter is provided
if [ "$1" = "all" ]; then
    echo "Running PDF generation in Docker (regenerating all)..."
    docker run --rm -v "$(pwd):/workspace" -w /workspace -e ALL=1 pdf-generator bash scripts/internal/gen_all.sh
else
    echo "Running PDF generation in Docker..."
    docker run --rm -v "$(pwd):/workspace" -w /workspace pdf-generator bash scripts/internal/gen_all.sh
fi

echo "Done!"
