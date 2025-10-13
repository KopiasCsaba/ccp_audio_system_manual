#!/bin/bash
# Convenience wrapper for development script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/scripts/development.sh" "$@"
