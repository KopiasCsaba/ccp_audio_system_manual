#!/bin/bash
# Load and play a file in VLC via HTTP API

# Configuration
VLC_HOST="${VLC_HOST:-192.168.1.200}"
VLC_PORT="${VLC_PORT:-8081}"
VLC_PASSWORD="${VLC_PASSWORD:-vlcremote}"
MEDIA_FILE="$1"

# Check if media file is provided
if [ -z "$MEDIA_FILE" ]; then
    echo "Usage: $0 <media_file>" >&2
    echo "Example: $0 /media/nas/video.mp4" >&2
    echo "" >&2
    echo "Environment variables:" >&2
    echo "  VLC_HOST=192.168.1.200  - VLC server host (default: localhost)" >&2
    echo "  VLC_PORT=8081           - VLC HTTP port (default: 8081)" >&2
    echo "  VLC_PASSWORD=vlcremote  - VLC HTTP password (default: vlcremote)" >&2
    echo "" >&2
    exit 1
fi

# Convert file path to file:// URI if it's an absolute path
if [[ "$MEDIA_FILE" = /* ]]; then
    MEDIA_URI="file://$MEDIA_FILE"
else
    MEDIA_URI="$MEDIA_FILE"
fi

# URL encode the URI
ENCODED_URI=$(printf %s "$MEDIA_URI" | jq -sRr @uri)

# VLC HTTP API endpoint
VLC_URL="http://${VLC_HOST}:${VLC_PORT}/requests/status.json"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Loading file in VLC..." >&2
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Host: $VLC_HOST:$VLC_PORT" >&2
echo "[$(date '+%Y-%m-%d %H:%M:%S')] File: $MEDIA_FILE" >&2

# Clear playlist
curl -s -u ":$VLC_PASSWORD"  "${VLC_URL}?command=pl_empty"  > /dev/null || { echo "[$(date '+%Y-%m-%d %H:%M:%S')] Error: Failed to clear playlist" >&2; exit 1; }

# Add file to playlist
curl -s -u ":$VLC_PASSWORD" "${VLC_URL}?command=in_enqueue&input=${ENCODED_URI}"  > /dev/null || { echo "[$(date '+%Y-%m-%d %H:%M:%S')] Error: Failed to add file to playlist" >&2; exit 1; }

# Detect if the file is an image (common image extensions)
if [[ "$MEDIA_FILE" =~ \.(jpg|jpeg|png|gif|bmp|webp|svg)$ ]]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Image detected, enabling repeat mode..." >&2

    # Get current repeat state
    CURRENT_REPEAT=$(curl -s -u ":$VLC_PASSWORD" "${VLC_URL}" 2>/dev/null | jq -r '.repeat // "false"' 2>/dev/null)

    # Enable repeat mode so the image stays on screen (only toggle if currently off)
    if [ "$CURRENT_REPEAT" != "true" ]; then
        curl -s -u ":$VLC_PASSWORD" "${VLC_URL}?command=pl_repeat"  > /dev/null
    fi
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Video detected, disabling repeat mode..." >&2

    # Get current repeat state
    CURRENT_REPEAT=$(curl -s -u ":$VLC_PASSWORD" "${VLC_URL}" 2>/dev/null | jq -r '.repeat // "false"' 2>/dev/null)

    # Disable repeat mode for videos (only toggle if currently on)
    if [ "$CURRENT_REPEAT" = "true" ]; then
        curl -s -u ":$VLC_PASSWORD" "${VLC_URL}?command=pl_repeat"  > /dev/null
    fi
fi

# Start playback
curl -s -u ":$VLC_PASSWORD" "${VLC_URL}?command=pl_play"  > /dev/null || { echo "[$(date '+%Y-%m-%d %H:%M:%S')] Error: Failed to start playback" >&2; exit 1; }

echo "[$(date '+%Y-%m-%d %H:%M:%S')] File loaded successfully" >&2
