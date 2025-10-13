#!/bin/bash

# Build script for evdevrelay with CGO support
# Builds binaries for x86_64 and ARM (Raspberry Pi Zero W)

set -e

# Get the directory where this script is located and the project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_DIR"

VERSION=${VERSION:-"1.0.0"}
BUILD_DIR="build"
# Static linking flags for fully self-contained binary
# -s -w: strip debug info to reduce size
# -extldflags '-static': force static linking of C libraries
# -linkmode external: use external linker for static linking
LDFLAGS="-s -w -X main.Version=${VERSION} -extldflags '-static' -linkmode external"
# Build tags for pure Go implementations where possible
BUILD_TAGS="netgo osusergo"

echo "Building evdevrelay v${VERSION}"
echo "================================"
echo ""

# Check for required tools
echo "Checking build requirements..."

# Check for Go
if ! command -v go &> /dev/null; then
    echo "ERROR: Go is not installed"
    echo "Please install Go 1.21 or later from https://go.dev/dl/"
    exit 1
fi

# Check for gcc (needed for CGO)
if ! command -v gcc &> /dev/null; then
    echo "ERROR: gcc is not installed (required for CGO)"
    echo "Please install build tools:"
    echo "  Ubuntu/Debian: sudo apt-get install build-essential"
    echo "  Fedora/RHEL:   sudo dnf install gcc"
    echo "  Arch:          sudo pacman -S base-devel"
    exit 1
fi

# Check for cross-compilation tools for ARM
ARM_CROSS_COMPILE=1
if ! command -v arm-linux-gnueabihf-gcc &> /dev/null && ! command -v arm-linux-gnueabi-gcc &> /dev/null; then
    echo "WARNING: ARM cross-compiler not found"
    echo "ARM builds will be skipped. To enable ARM builds, install cross-compilation tools:"
    echo "  Ubuntu/Debian: sudo apt-get install gcc-arm-linux-gnueabihf gcc-aarch64-linux-gnu"
    echo "  Fedora/RHEL:   sudo dnf install gcc-arm-linux-gnu gcc-aarch64-linux-gnu"
    ARM_CROSS_COMPILE=0
fi

echo "✓ Go version: $(go version | awk '{print $3}')"
echo "✓ GCC found: $(gcc --version | head -n1)"
echo ""

# Download dependencies if go.sum doesn't exist or is incomplete
if [ ! -f "go.sum" ] || ! grep -q "github.com/gvalkov/golang-evdev" go.sum 2>/dev/null; then
    echo "Downloading dependencies..."
    go mod download
    go mod tidy
    echo "✓ Dependencies ready"
    echo ""
fi

# Create build directory
mkdir -p "${BUILD_DIR}"

# Build for x86_64 (AMD64)
echo ""
echo "Building for Linux x86_64 (static binary)..."
CGO_ENABLED=1 GOOS=linux GOARCH=amd64 go build \
    -tags="${BUILD_TAGS}" \
    -ldflags="${LDFLAGS}" \
    -o "${BUILD_DIR}/evdevrelay-linux-amd64" \
    ./src

echo "✓ Built: ${BUILD_DIR}/evdevrelay-linux-amd64"
ls -lh "${BUILD_DIR}/evdevrelay-linux-amd64"
echo "Checking binary type..."
file "${BUILD_DIR}/evdevrelay-linux-amd64"

# Build ARM variants if cross-compiler is available
if [ $ARM_CROSS_COMPILE -eq 1 ]; then
    # Determine which ARM compiler to use
    if command -v arm-linux-gnueabihf-gcc &> /dev/null; then
        ARM_CC="arm-linux-gnueabihf-gcc"
    elif command -v arm-linux-gnueabi-gcc &> /dev/null; then
        ARM_CC="arm-linux-gnueabi-gcc"
    fi

    # Build for ARM (Raspberry Pi Zero W - ARMv6)
    echo ""
    echo "Building for Linux ARM (Raspberry Pi Zero W - ARMv6, static binary)..."
    CGO_ENABLED=1 GOOS=linux GOARCH=arm GOARM=6 CC="${ARM_CC}" go build \
        -tags="${BUILD_TAGS}" \
        -ldflags="${LDFLAGS}" \
        -o "${BUILD_DIR}/evdevrelay-linux-arm6" \
        ./src

    echo "✓ Built: ${BUILD_DIR}/evdevrelay-linux-arm6"
    ls -lh "${BUILD_DIR}/evdevrelay-linux-arm6"
    echo "Checking binary type..."
    file "${BUILD_DIR}/evdevrelay-linux-arm6"

    # Build for ARM7 (Raspberry Pi 2/3/4)
    echo ""
    echo "Building for Linux ARM7 (Raspberry Pi 2/3/4, static binary)..."
    CGO_ENABLED=1 GOOS=linux GOARCH=arm GOARM=7 CC="${ARM_CC}" go build \
        -tags="${BUILD_TAGS}" \
        -ldflags="${LDFLAGS}" \
        -o "${BUILD_DIR}/evdevrelay-linux-arm7" \
        ./src

    echo "✓ Built: ${BUILD_DIR}/evdevrelay-linux-arm7"
    ls -lh "${BUILD_DIR}/evdevrelay-linux-arm7"
    echo "Checking binary type..."
    file "${BUILD_DIR}/evdevrelay-linux-arm7"

    # Build for ARM64 if compiler is available
    if command -v aarch64-linux-gnu-gcc &> /dev/null; then
        echo ""
        echo "Building for Linux ARM64 (Raspberry Pi 3/4/5 64-bit, static binary)..."
        CGO_ENABLED=1 GOOS=linux GOARCH=arm64 CC="aarch64-linux-gnu-gcc" go build \
            -tags="${BUILD_TAGS}" \
            -ldflags="${LDFLAGS}" \
            -o "${BUILD_DIR}/evdevrelay-linux-arm64" \
            ./src

        echo "✓ Built: ${BUILD_DIR}/evdevrelay-linux-arm64"
        ls -lh "${BUILD_DIR}/evdevrelay-linux-arm64"
        echo "Checking binary type..."
        file "${BUILD_DIR}/evdevrelay-linux-arm64"
    else
        echo ""
        echo "Skipping ARM64 build (aarch64-linux-gnu-gcc not found)"
    fi
else
    echo ""
    echo "Skipping ARM builds (cross-compiler not available)"
    echo "To build for ARM, install cross-compilation tools and re-run this script"
fi

echo ""
echo "================================"
echo "Build complete! Binaries are in ${BUILD_DIR}/"
echo ""
echo "Built binaries (statically linked, no shared library dependencies):"
if [ -f "${BUILD_DIR}/evdevrelay-linux-amd64" ]; then
    echo "✓ x86_64: evdevrelay-linux-amd64"
fi
if [ -f "${BUILD_DIR}/evdevrelay-linux-arm6" ]; then
    echo "✓ ARM (Pi Zero W): evdevrelay-linux-arm6"
fi
if [ -f "${BUILD_DIR}/evdevrelay-linux-arm7" ]; then
    echo "✓ ARM7 (Pi 2/3/4): evdevrelay-linux-arm7"
fi
if [ -f "${BUILD_DIR}/evdevrelay-linux-arm64" ]; then
    echo "✓ ARM64 (Pi 3/4/5): evdevrelay-linux-arm64"
fi
echo ""
echo "Binaries are self-contained and require no external dependencies."
echo "They can be copied to any Linux system of the same architecture."
echo ""
