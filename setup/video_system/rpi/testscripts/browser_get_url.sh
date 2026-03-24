#!/bin/bash
# Load a URL in Brave browser via HTTP API

# Configuration
BROWSER_HOST="${BROWSER_HOST:-192.168.1.200}"
BROWSER_PORT="${BROWSER_PORT:-9393}"
TARGET_URL="$1"

# Browser HTTP API endpoint
BROWSER_URL="http://${BROWSER_HOST}:${BROWSER_PORT}/"


# Send command to browser server
curl -s -X GET "$BROWSER_URL" \
    || { echo "[$(date '+%Y-%m-%d %H:%M:%S')] Error: Failed to communicate with browser server" >&2; exit 1; }

