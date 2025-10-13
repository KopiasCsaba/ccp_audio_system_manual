#!/bin/bash

# Development script that watches for file changes and rebuilds/restarts the application
# Requires: inotify-tools (install with: sudo apt-get install inotify-tools)

set -e

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

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# PID of the running application
APP_PID=""

# Check for inotify-tools
if ! command -v inotifywait &> /dev/null; then
    echo -e "${RED}ERROR: inotifywait is not installed${NC}"
    echo "Install it with:"
    echo "  Ubuntu/Debian: sudo apt-get install inotify-tools"
    echo "  Fedora/RHEL:   sudo dnf install inotify-tools"
    echo "  Arch:          sudo pacman -S inotify-tools"
    exit 1
fi

# Function to kill the running application
kill_app() {
    if [ ! -z "$APP_PID" ] && kill -0 "$APP_PID" 2>/dev/null; then
        echo -e "${YELLOW}Stopping application (PID: $APP_PID)...${NC}"
        kill "$APP_PID" 2>/dev/null || true
        wait "$APP_PID" 2>/dev/null || true
        APP_PID=""
    fi
}

# Function to build and run
build_and_run() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}Building application...${NC}"
    echo -e "${BLUE}========================================${NC}"

    # Kill existing app first
    kill_app

    # Build
    if ./scripts/build-x86_64.sh; then
        echo -e "${GREEN}✓ Build successful${NC}"

        echo -e "\n${BLUE}========================================${NC}"
        echo -e "${BLUE}Starting application...${NC}"
        echo -e "${BLUE}========================================${NC}"

        # Run the application in the background
        ./scripts/run-example.sh &
        APP_PID=$!

        echo -e "${GREEN}✓ Application started (PID: $APP_PID)${NC}"
        echo -e "${YELLOW}Watching for changes... (Press Ctrl+C to stop)${NC}\n"
    else
        echo -e "${RED}✗ Build failed${NC}"
        echo -e "${YELLOW}Fix the errors and save to retry...${NC}\n"
    fi
}

# Cleanup on exit
cleanup() {
    echo -e "\n${YELLOW}Shutting down...${NC}"
    kill_app
    exit 0
}

trap cleanup EXIT INT TERM

# Initial build and run
build_and_run

# Watch for changes in Go files
echo -e "${GREEN}Development mode active!${NC}"
echo -e "${BLUE}Watching: *.go files${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop${NC}\n"

# Watch for changes and rebuild/restart
inotifywait -m -e close_write,moved_to,create --format '%w%f' src/*.go 2>/dev/null | while read FILE
do
    echo -e "\n${YELLOW}File changed: $FILE${NC}"
    sleep 0.5  # Debounce: wait a bit in case multiple files are saved

    # Consume any additional events that happened during the sleep
    while read -t 0.1 FILE; do
        echo -e "${YELLOW}File changed: $FILE${NC}"
    done

    build_and_run
done
