#!/bin/bash

# Build script for x86_64 (AMD64) only with CGO

set -e

# Get the directory where this script is located and the project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_DIR"

VERSION=${VERSION:-"1.0.0"}
BUILD_DIR="build"
LDFLAGS="-s -w -X main.Version=${VERSION}"

echo "Building evdevrelay v${VERSION} for x86_64"
echo ""

# Check for gcc
if ! command -v gcc &> /dev/null; then
    echo "ERROR: gcc is not installed (required for CGO)"
    echo "Please install build tools:"
    echo "  Ubuntu/Debian: sudo apt-get install build-essential"
    echo "  Fedora/RHEL:   sudo dnf install gcc"
    echo "  Arch:          sudo pacman -S base-devel"
    exit 1
fi

# Download dependencies if needed
if [ ! -f "go.sum" ] || ! grep -q "github.com/gvalkov/golang-evdev" go.sum 2>/dev/null; then
    echo "Downloading dependencies..."
    go mod download
    go mod tidy
    echo "✓ Dependencies ready"
    echo ""
fi

# Create build directory
mkdir -p "${BUILD_DIR}"

# Build for x86_64
echo "Building..."
CGO_ENABLED=1 GOOS=linux GOARCH=amd64 go build \
    -ldflags="${LDFLAGS}" \
    -o "${BUILD_DIR}/evdevrelay-linux-amd64" \
    ./src

echo "✓ Built: ${BUILD_DIR}/evdevrelay-linux-amd64"
ls -lh "${BUILD_DIR}/evdevrelay-linux-amd64"
