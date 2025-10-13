#!/bin/bash

# Example script to run evdevrelay with custom configuration

# Get the directory where this script is located and the project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_DIR"

# Load .env file if it exists
if [ -f ".env" ]; then
    echo "Loading configuration from .env file..."
    set -a  # automatically export all variables
    source .env
    set +a
fi

# Set your OSC server details (with defaults if not set in .env)
export OSC_HOST="${OSC_HOST:-localhost}"
export OSC_PORT="${OSC_PORT:-8000}"
export RECONNECT_DELAY="${RECONNECT_DELAY:-5}"
export SCAN_INTERVAL="${SCAN_INTERVAL:-5}"

echo "======================================"
echo "EvdevRelay - Configuration"
echo "======================================"
echo "OSC Host:        $OSC_HOST"
echo "OSC Port:        $OSC_PORT"
echo "Reconnect Delay: ${RECONNECT_DELAY}s"
echo "Scan Interval:   ${SCAN_INTERVAL}s"
echo "======================================"
echo ""

# Detect architecture and select appropriate binary
ARCH=$(uname -m)
case "$ARCH" in
    x86_64|amd64)
        BINARY="build/evdevrelay-linux-amd64"
        ;;
    armv6l)
        BINARY="build/evdevrelay-linux-arm6"
        ;;
    armv7l)
        BINARY="build/evdevrelay-linux-arm7"
        ;;
    aarch64|arm64)
        BINARY="build/evdevrelay-linux-arm64"
        ;;
    *)
        echo "Unknown architecture: $ARCH"
        echo "Please specify binary manually"
        exit 1
        ;;
esac

if [ ! -f "$BINARY" ]; then
    echo "Binary not found: $BINARY"
    echo "Please run './build.sh' first to build the application"
    exit 1
fi

echo "Using binary: $BINARY"
echo ""

# Check for permissions
if [ ! -r /dev/input/event0 ] 2>/dev/null; then
    echo "WARNING: Cannot read /dev/input/event0"
    echo "You may need to run this script with sudo or add your user to the 'input' group:"
    echo "  sudo usermod -a -G input $USER"
    echo ""
fi

echo "Starting evdevrelay..."
echo "Press Ctrl+C to stop"
echo ""

# Run the binary
exec "$BINARY"
