#!/bin/bash

# Build script for ARM (Raspberry Pi Zero W - ARMv6) only with CGO cross-compilation

set -e

# Get the directory where this script is located and the project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_DIR"

VERSION=${VERSION:-"1.0.0"}
BUILD_DIR="build"
LDFLAGS="-s -w -X main.Version=${VERSION}"

echo "Building evdevrelay v${VERSION} for ARM (Raspberry Pi Zero W)"
echo ""

# Check for ARM cross-compiler
if ! command -v arm-linux-gnueabihf-gcc &> /dev/null && ! command -v arm-linux-gnueabi-gcc &> /dev/null; then
    echo "ERROR: ARM cross-compiler not found"
    echo "Please install cross-compilation tools:"
    echo "  Ubuntu/Debian: sudo apt-get install gcc-arm-linux-gnueabihf"
    echo "  Fedora/RHEL:   sudo dnf install gcc-arm-linux-gnu"
    exit 1
fi

# Determine which ARM compiler to use
if command -v arm-linux-gnueabihf-gcc &> /dev/null; then
    ARM_CC="arm-linux-gnueabihf-gcc"
    echo "Using compiler: arm-linux-gnueabihf-gcc"
elif command -v arm-linux-gnueabi-gcc &> /dev/null; then
    ARM_CC="arm-linux-gnueabi-gcc"
    echo "Using compiler: arm-linux-gnueabi-gcc"
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

# Build for ARM6 (Raspberry Pi Zero W)
echo "Building..."
CGO_ENABLED=1 GOOS=linux GOARCH=arm GOARM=6 CC="${ARM_CC}" go build \
    -ldflags="${LDFLAGS}" \
    -o "${BUILD_DIR}/evdevrelay-linux-arm6" \
    ./src

echo "✓ Built: ${BUILD_DIR}/evdevrelay-linux-arm6"
ls -lh "${BUILD_DIR}/evdevrelay-linux-arm6"
