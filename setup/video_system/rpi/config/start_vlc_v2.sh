#!/bin/bash
# VLC X11 fullscreen for Raspberry Pi 5 - Screen 0 (HDMI-A-1) - v2
# Note: Managed by systemd (vlc.service) - dependencies and restarts handled by systemd
#
# Purpose:
# This script is designed to:
# - NOT accept any input parameters (always starts with default READY screen)
# - Start VLC without a file, then load a static "VLC IS READY" PNG via HTTP API
# - Start a VLC instance listening for HTTP commands to control playback
# - By default, the ready image loops continuously (via HTTP API repeat mode)
# - Support playing images and videos, even if larger than screen size (will scale)
# - Utilize hardware acceleration for video decoding via VAAPI
# - Use X11 video output on Screen 0 (DISPLAY=:0, HDMI-A-1)
# - Ready image is generated using ImageMagick if it doesn't exist
# - Position and constrain window using Openbox
#
# Configuration:
# - Display: Fixed to :0 (HDMI-A-1)
# - Audio: vc4hdmi0 (HDMI-A-1 audio output)
# - Window: Positioned at 0,0 with 1920x1080 size
#
# The VLC instance remains running and waiting for HTTP API commands to load
# and play new media files (images or videos) via the web interface.

# Configuration (no parameters - always start with ready screen)
DEBUG="${DEBUG:-no}"
READY_IMAGE="/tmp/vlc_ready.png"

# HTTP API Configuration
VLC_HTTP_HOST="${VLC_HTTP_HOST:-0.0.0.0}"
VLC_HTTP_PORT="${VLC_HTTP_PORT:-8081}"
VLC_HTTP_PASSWORD="${VLC_HTTP_PASSWORD:-vlcremote}"  # Empty password = no authentication required

# Display and Audio Configuration
# DISPLAY is set by systemd via EnvironmentFile
AUDIO_CARD="vc4hdmi0"

# Wait for VLC HTTP API to be ready
wait_for_vlc_api() {
    local max_wait=10
    local waited=0
    local vlc_url="http://localhost:${VLC_HTTP_PORT}/requests/status.json"

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Waiting for VLC HTTP API..." >&2

    while [ $waited -lt $max_wait ]; do
        if curl -s -u ":$VLC_HTTP_PASSWORD" "$vlc_url" > /dev/null 2>&1; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] VLC HTTP API ready" >&2
            return 0
        fi
        sleep 0.5
        waited=$((waited + 1))
    done

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: VLC HTTP API not ready after ${max_wait}s" >&2
    return 1
}

# Create ready image if it doesn't exist
if [ ! -f "$READY_IMAGE" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Creating READY image..." >&2
    mkdir -p "$(dirname "$READY_IMAGE")"

    if ! command -v convert &> /dev/null; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: ImageMagick not installed" >&2
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Install with: sudo apt-get install imagemagick" >&2
        exit 1
    fi

    # Create 1920x1080 PNG with "VLC IS READY" text
    convert -size 1920x1080 xc:black \
            -font DejaVu-Sans-Bold \
            -pointsize 120 \
            -fill white \
            -gravity center \
            -annotate +0+0 "VLC IS READY" \
            "$READY_IMAGE"

    if [ ! -f "$READY_IMAGE" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Failed to create $READY_IMAGE" >&2
        exit 1
    fi
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Successfully generated $READY_IMAGE" >&2
fi

# Build VLC arguments
VLC_ARGS=(
    # === Interface Settings ===
    -I dummy                # Use dummy interface (no GUI)
    --no-video-title-show   # Don't show media title overlaid on video

    # === Video Output ===
    --vout=x11              # Use X11 video output
    --no-video-deco         # No window decorations (borderless)
    --autoscale             # Autoscale video to fit window
    --swscale-mode=2        # High quality scaling (bicubic)
    # Note: No --fullscreen flag - let Openbox manage window geometry
    # The window will be sized 1920x1080 by openbox, video will scale to fit

    # === Audio Output ===
    --aout=alsa             # Use ALSA for audio output
    --alsa-audio-device="hdmi:CARD=$AUDIO_CARD,DEV=0"
                            # Route audio to HDMI output

    # === Hardware Acceleration ===
    #--avcodec-hw=any        # Use any available hardware acceleration
    --avcodec-hw=vaapi

    # === Playback Control ===
    --no-loop               # Don't loop (looping controlled per-media via HTTP API)
    --no-repeat             # Don't repeat playlist
    --no-play-and-exit      # Don't exit VLC when playback ends (keep running for HTTP control)

    # === Caching/Buffering ===
    --file-caching=300      # File caching in milliseconds
    --network-caching=1000  # Network caching in milliseconds

    # === Audio Settings ===
    --gain=0.8              # Audio gain/volume multiplier

    # === Interface ===
    --no-dbus               # Disable D-Bus control interface

    # === HTTP Remote Control Interface ===
    --extraintf=http        # Enable HTTP interface as an additional interface
    --http-host="$VLC_HTTP_HOST"     # Listen on all network interfaces (allows remote control)
    --http-port="$VLC_HTTP_PORT"     # Port for HTTP API (default 8081 to avoid conflicts)
    --http-password="$VLC_HTTP_PASSWORD"  # Password for HTTP API access (empty = no auth required)

    # === Window Size ===
    --width=1920            # Window width
    --height=1080           # Window height
    --no-media-library
    --no-auto-preparse
    --dvd=/dev/null   # Points dvdnav at /dev/null so it fails silently instead of trying the SD card
    #--verbose=2
)

# Add debug mode if requested
if [ "$DEBUG" = "yes" ]; then
    VLC_ARGS+=(--verbose=2)
fi

# Log the command
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting VLC on X11" >&2
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Display: $DISPLAY (HDMI-A-1)" >&2
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Audio: $AUDIO_CARD" >&2
if [ -z "$VLC_HTTP_PASSWORD" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] HTTP API: http://$VLC_HTTP_HOST:$VLC_HTTP_PORT (no authentication)" >&2
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] HTTP API: http://$VLC_HTTP_HOST:$VLC_HTTP_PORT (password: $VLC_HTTP_PASSWORD)" >&2
fi

if [ "$DEBUG" = "yes" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] VLC Args: ${VLC_ARGS[*]}" >&2
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Launching VLC (no file)..." >&2

# Start VLC without any file initially
# Openbox window manager will enforce the window geometry
# systemd will restart if it crashes
vlc "${VLC_ARGS[@]}" &
VLC_PID=$!

# Wait for VLC HTTP API to become ready
if wait_for_vlc_api; then
    # Load the ready image via HTTP API
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Loading ready image via HTTP API..." >&2

    VLC_URL="http://localhost:${VLC_HTTP_PORT}/requests/status.json"
    READY_URI="file://$READY_IMAGE"
    ENCODED_URI=$(printf %s "$READY_URI")

    # Clear playlist
    curl -s -u ":$VLC_HTTP_PASSWORD" "${VLC_URL}?command=pl_empty" > /dev/null

    # Add ready image to playlist
    curl -s -u ":$VLC_HTTP_PASSWORD" "${VLC_URL}?command=in_enqueue&input=${ENCODED_URI}" > /dev/null

    # Enable repeat mode for the image to stay on screen
    curl -s -u ":$VLC_HTTP_PASSWORD" "${VLC_URL}?command=pl_repeat" > /dev/null

    # Start playback
    curl -s -u ":$VLC_HTTP_PASSWORD" "${VLC_URL}?command=pl_play" > /dev/null

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Ready image loaded successfully" >&2
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: Could not load ready image" >&2
fi

# Wait for VLC to exit (it shouldn't with --no-play-and-exit)
# If it does exit, systemd will restart it
wait $VLC_PID
