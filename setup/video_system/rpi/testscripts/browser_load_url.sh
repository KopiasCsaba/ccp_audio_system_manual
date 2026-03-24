#!/bin/bash
# Load a URL in Brave browser via HTTP API

# Configuration
BROWSER_HOST="${BROWSER_HOST:-192.168.1.200}"
BROWSER_PORT="${BROWSER_PORT:-9393}"
TARGET_URL="$1"

# Check if URL is provided
if [ -z "$TARGET_URL" ]; then
    echo "Usage: $0 <url>" >&2
    echo "Example: $0 https://example.com" >&2
    echo "Example: $0 file:///config/media/foo.html" >&2
    echo "" >&2
    echo "Environment variables:" >&2
    echo "  BROWSER_HOST=192.168.1.200  - Browser server host (default: 192.168.1.200)" >&2
    echo "  BROWSER_PORT=9393           - Browser server port (default: 9393)" >&2
    echo "" >&2
    exit 1
fi

# Browser HTTP API endpoint
BROWSER_URL="http://${BROWSER_HOST}:${BROWSER_PORT}/"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Loading URL in browser..." >&2
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Host: $BROWSER_HOST:$BROWSER_PORT" >&2
echo "[$(date '+%Y-%m-%d %H:%M:%S')] URL: $TARGET_URL" >&2

# Send command to browser server
curl -s -X POST -G --data-urlencode "url=$TARGET_URL" "$BROWSER_URL" \
    || { echo "[$(date '+%Y-%m-%d %H:%M:%S')] Error: Failed to communicate with browser server" >&2; exit 1; }

echo "" >&2
echo "[$(date '+%Y-%m-%d %H:%M:%S')] URL loaded successfully" >&2
