#!/usr/bin/env python3
"""
Simple OSC server for testing evdevrelay
Requires: pip install python-osc
"""

from pythonosc import dispatcher, osc_server
import sys

def evdev_handler(unused_addr, *args):
    """Handle evdev messages"""
    print(f"[EVDEV] {unused_addr} = {args}")

def default_handler(unused_addr, *args):
    """Handle all other OSC messages"""
    print(f"[OSC] {unused_addr} = {args}")

if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8000

    print(f"Starting OSC test server on port {port}")
    print("Listening for evdev events...")
    print("Press Ctrl+C to stop")
    print("-" * 50)

    disp = dispatcher.Dispatcher()
    disp.map("/evdev/*", evdev_handler)
    disp.set_default_handler(default_handler)

    server = osc_server.ThreadingOSCUDPServer(("0.0.0.0", port), disp)

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down...")
        server.shutdown()
