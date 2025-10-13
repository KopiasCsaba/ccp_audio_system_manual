#!/bin/bash
# Convenience wrapper for build script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/scripts/build.sh" "$@"
