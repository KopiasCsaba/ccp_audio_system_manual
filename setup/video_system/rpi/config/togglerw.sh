#!/bin/bash
#
# togglerw.sh - Toggle read-only/read-write root filesystem
# Uses raspi-config nonint commands to manage overlay filesystem
#

set -e

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root (use sudo)"
    exit 1
fi

# Check current overlay status
# raspi-config nonint get_overlay returns:
#   0 = overlay enabled (read-only)
#   1 = overlay disabled (read-write)
CURRENT_STATUS=$(raspi-config nonint get_overlay_now || echo "255")

if [ "$CURRENT_STATUS" = "255" ]; then
    echo "Error: Unable to determine overlay filesystem status"
    echo "Is raspi-config installed?"
    exit 1
fi

# Display current status
echo "Current root filesystem status:"
if [ "$CURRENT_STATUS" = "0" ]; then
    echo "  READ-ONLY (overlay filesystem enabled)"
    NEW_ACTION="disable overlay (enable read-write mode)"
    NEW_MODE="read-write"
else
    echo "  READ-WRITE (overlay filesystem disabled)"
    NEW_ACTION="enable overlay (enable read-only mode)"
    NEW_MODE="read-only"
fi

echo ""
echo "Press ENTER to $NEW_ACTION, or Ctrl+C to cancel"
read -r

# Toggle the overlay
if [ "$CURRENT_STATUS" = "0" ]; then
    echo "Disabling overlay filesystem (switching to read-write)..."
    raspi-config nonint disable_overlayfs
else
    echo "Enabling overlay filesystem (switching to read-only)..."
    raspi-config nonint enable_overlayfs
fi

echo ""
echo "Overlay filesystem toggled successfully!"
echo "System will boot in $NEW_MODE mode after reboot."
echo ""
echo "Run 'sudo reboot' to apply changes."
