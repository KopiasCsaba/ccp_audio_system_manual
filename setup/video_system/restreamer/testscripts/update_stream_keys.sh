#!/bin/bash
# Update Restreamer egress stream keys for YouTube (single key) or Facebook (primary + backup keys)
# Usage:
#   YouTube: ./update_stream_keys.sh <process_id> <stream_key>
#   Facebook: ./update_stream_keys.sh <process_id> <primary_key> <backup_key>

set -euo pipefail

RESTREAMER_HOST="${RESTREAMER_HOST:-http://127.0.0.1:8080}"
PROCESS_ID="${1:-}"

if [ -z "$PROCESS_ID" ]; then
    echo "Usage: $0 <process_id> <stream_key> [backup_key]"
    echo "  YouTube:  $0 'restreamer-ui:egress:youtube:xxx' 'your_key'"
    echo "  Facebook: $0 'restreamer-ui:egress:facebook:xxx' 'primary_key' 'backup_key'"
    exit 1
fi

# Detect platform
if [[ "$PROCESS_ID" =~ :youtube: ]]; then
    PLATFORM="youtube"
    STREAM_KEY="${2:-}"
    [ -z "$STREAM_KEY" ] && { echo "Error: stream_key required"; exit 1; }
elif [[ "$PROCESS_ID" =~ :facebook: ]]; then
    PLATFORM="facebook"
    PRIMARY_KEY="${2:-}"
    BACKUP_KEY="${3:-}"
    [ -z "$PRIMARY_KEY" ] || [ -z "$BACKUP_KEY" ] && { echo "Error: both primary_key and backup_key required"; exit 1; }
else
    echo "Error: Invalid process ID"
    exit 1
fi

PROCESS_ID_ENC=$(printf '%s' "$PROCESS_ID" | jq -sRr @uri)
API_PROCESS="${RESTREAMER_HOST}/api/v3/process/${PROCESS_ID_ENC}"
API_METADATA="${API_PROCESS}/metadata/restreamer-ui"

echo "Platform: $PLATFORM"

# Get current config and metadata
CONFIG=$(curl -s "$API_PROCESS" | jq '.config')
METADATA=$(curl -s "$API_METADATA")


if [ "$PLATFORM" = "youtube" ]; then
    echo "Stream key: $STREAM_KEY"

    # Update config outputs
    CONFIG=$(echo "$CONFIG" | jq --arg key "$STREAM_KEY" '
        .output[0].address = "rtmps://a.rtmp.youtube.com/live2/\($key)" |
        .output[1].address = "rtmps://b.rtmp.youtube.com/live2?backup=1/\($key)"
    ')

    # Update metadata
    METADATA=$(echo "$METADATA" | jq --arg key "$STREAM_KEY" '
        .settings.stream_key = $key |
        .outputs[0].address = "rtmps://a.rtmp.youtube.com/live2/\($key)" |
        .outputs[1].address = "rtmps://b.rtmp.youtube.com/live2?backup=1/\($key)"
    ')
else
    echo "Primary key: $PRIMARY_KEY"
    echo "Backup key: $BACKUP_KEY"

    # Update config outputs
    CONFIG=$(echo "$CONFIG" | jq --arg p "$PRIMARY_KEY" --arg b "$BACKUP_KEY" '
        .output[0].address = "rtmps://live-api-s.facebook.com:443/rtmp/\($p)" |
        .output[1].address = "rtmps://live-api-s.facebook.com:443/rtmp/\($b)"
    ')

    # Update metadata
    METADATA=$(echo "$METADATA" | jq --arg p "$PRIMARY_KEY" --arg b "$BACKUP_KEY" '
        .settings.stream_key_primary = $p |
        .settings.stream_key_backup = $b |
        .outputs[0].address = "rtmps://live-api-s.facebook.com:443/rtmp/\($p)" |
        .outputs[1].address = "rtmps://live-api-s.facebook.com:443/rtmp/\($b)"
    ')
fi

# Update config
curl -s -X PUT -H "Content-Type: application/json" -d "$CONFIG" "$API_PROCESS" > /dev/null

# Update metadata (using correct endpoint with /restreamer-ui key)
curl -s -X PUT -H "Content-Type: application/json" -d "$METADATA" "$API_METADATA" > /dev/null

echo "✓ Stream key(s) updated successfully!"
