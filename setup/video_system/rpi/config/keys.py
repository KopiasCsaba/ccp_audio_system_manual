#!/usr/bin/env python3
"""Monitor all input devices and output key events in a standardized format."""


# apt-get install python3-aiohttp python3-evdev
import asyncio
import sys
import json
from pathlib import Path
from evdev import InputDevice, ecodes, list_devices, categorize
import aiohttp
from pprint import pprint

# Global HTTP session for connection reuse
_session = None
_hook_url = None

# Modifier key codes
MODIFIER_KEYS = {
    29: 'ctrl',    # LEFT_CTRL
    97: 'ctrl',    # RIGHT_CTRL
    42: 'shift',   # LEFT_SHIFT
    54: 'shift',   # RIGHT_SHIFT
    56: 'alt',     # LEFT_ALT
    100: 'alt',    # RIGHT_ALT
    125: 'meta',   # LEFT_META (Windows key)
    126: 'meta',   # RIGHT_META
}

# Key code to character mapping (unshifted)
KEY_CHARS = {
    # Letters
    30: 'a', 48: 'b', 46: 'c', 32: 'd', 18: 'e', 33: 'f', 34: 'g', 35: 'h',
    23: 'i', 36: 'j', 37: 'k', 38: 'l', 50: 'm', 49: 'n', 24: 'o', 25: 'p',
    16: 'q', 19: 'r', 31: 's', 20: 't', 22: 'u', 47: 'v', 17: 'w', 45: 'x',
    21: 'y', 44: 'z',
    # Numbers
    11: '0', 2: '1', 3: '2', 4: '3', 5: '4', 6: '5', 7: '6', 8: '7', 9: '8', 10: '9',
    # Special characters
    57: ' ',      # SPACE
    12: '-',      # MINUS
    13: '=',      # EQUAL
    26: '[',      # LEFT_BRACE
    27: ']',      # RIGHT_BRACE
    43: '\\',     # BACKSLASH
    39: ';',      # SEMICOLON
    40: "'",      # APOSTROPHE
    41: '`',      # GRAVE
    51: ',',      # COMMA
    52: '.',      # DOT
    53: '/',      # SLASH
    # Function and special keys
    28: '\n',     # ENTER
    14: '\b',     # BACKSPACE
    15: '\t',     # TAB
    1: '\x1b',    # ESC
}

# Key code to character mapping (shifted)
KEY_CHARS_SHIFT = {
    # Letters (uppercase)
    30: 'A', 48: 'B', 46: 'C', 32: 'D', 18: 'E', 33: 'F', 34: 'G', 35: 'H',
    23: 'I', 36: 'J', 37: 'K', 38: 'L', 50: 'M', 49: 'N', 24: 'O', 25: 'P',
    16: 'Q', 19: 'R', 31: 'S', 20: 'T', 22: 'U', 47: 'V', 17: 'W', 45: 'X',
    21: 'Y', 44: 'Z',
    # Numbers (symbols)
    11: ')', 2: '!', 3: '@', 4: '#', 5: '$', 6: '%', 7: '^', 8: '&', 9: '*', 10: '(',
    # Special characters (shifted)
    57: ' ',      # SPACE (no change)
    12: '_',      # MINUS -> UNDERSCORE
    13: '+',      # EQUAL -> PLUS
    26: '{',      # LEFT_BRACE -> LEFT_CURLY
    27: '}',      # RIGHT_BRACE -> RIGHT_CURLY
    43: '|',      # BACKSLASH -> PIPE
    39: ':',      # SEMICOLON -> COLON
    40: '"',      # APOSTROPHE -> QUOTE
    41: '~',      # GRAVE -> TILDE
    51: '<',      # COMMA -> LESS_THAN
    52: '>',      # DOT -> GREATER_THAN
    53: '?',      # SLASH -> QUESTION
    # Function and special keys (no change)
    28: '\n',     # ENTER
    14: '\b',     # BACKSPACE
    15: '\t',     # TAB
    1: '\x1b',    # ESC
}

# Global modifier state (shared across all devices)
_modifier_state = {
    'ctrl': False,
    'shift': False,
    'alt': False,
    'meta': False,
}


def load_env():
    """Load HOOK_URL from keys.env file."""
    env_path = Path(__file__).parent / "keys.env"
    if not env_path.exists():
        return None

    with open(env_path) as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith('#'):
                if line.startswith('HOOK_URL='):
                    return line.split('=', 1)[1].strip().strip('"').strip("'")
    return None


def get_device_info(device):
    """Extract device ID and type from input device."""
    info = device.info
    vendor = f"{info.vendor:04x}"
    product = f"{info.product:04x}"
    devid = f"{vendor}:{product}"

    # Determine device type from name
    name = device.name.lower()
    if "keyboard" in name:
        devtype = "kbd"
    elif "mouse" in name:
        devtype = "m"
    elif "touchpad" in name:
        devtype = "tp"
    elif "touchscreen" in name:
        devtype = "ts"
    elif "gamepad" in name or "joystick" in name:
        devtype = "gp"
    else:
        devtype = "i"

    return devid, devtype


def get_key_char(code, shift_pressed):
    """Get the character representation of a key code.

    Args:
        code: The key code
        shift_pressed: Whether shift is currently pressed

    Returns:
        The character string, or None if not a printable/known key
    """
    if shift_pressed and code in KEY_CHARS_SHIFT:
        return KEY_CHARS_SHIFT[code]
    elif code in KEY_CHARS:
        return KEY_CHARS[code]
    return None


async def send_event(data):
    """Send event via HTTP POST - fire and forget, non-blocking."""
    global _session, _hook_url

    if not _hook_url:
        return

    try:
        # Send POST and immediately close response without reading body
        # This makes it truly fire-and-forget with minimal blocking
        async with _session.post(
            _hook_url,
            json=data,
            timeout=aiohttp.ClientTimeout(total=0.5),
        ) as resp:
            # Don't read response body - just close immediately
            # This allows the connection to be reused without waiting
            pass
    except asyncio.TimeoutError:
        pass  # Silently ignore timeouts
    except aiohttp.ClientError:
        pass  # Silently ignore client errors
    except Exception:
        pass  # Silently ignore any other errors


async def monitor_device(device_path):
    """Monitor a single input device for key events."""
    global _modifier_state

    try:
        device = InputDevice(device_path)
        devid, devtype = get_device_info(device)

        async for event in device.async_read_loop():
            if event.type == ecodes.EV_KEY:
                state = {0: "up", 1: "down", 2: "repeat"}.get(event.value, str(event.value))

                # Update modifier state if this is a modifier key
                if event.code in MODIFIER_KEYS:
                    modifier_name = MODIFIER_KEYS[event.code]
                    _modifier_state[modifier_name] = (event.value >= 1)  # True if pressed, False if released
                    # Don't send events for modifier-only key presses
                    continue



                # Get character value if available
                char_value = get_key_char(event.code, _modifier_state['shift'])

                # Build event data with modifier states
                event_data = {
                    "dev": devid,
                    "type": devtype,
                    "c": event.code,
                    "s": state,
                    "ms": {
                        "ctrl": _modifier_state['ctrl'],
                        "shift": _modifier_state['shift'],
                        "alt": _modifier_state['alt'],
                        "meta": _modifier_state['meta'],
                    }
                }

                # Add character value if available
                if char_value is not None:
                    event_data["v"] = char_value

                if state == "repeat" or devtype!="kbd":
                    continue

                if not _modifier_state['meta'] and event_data["s"]!="up" :
                    continue

                # Output as single-line JSON
                print(json.dumps(event_data,separators=(",", ":")), flush=True)

                # Send to webhook if configured
                asyncio.create_task(send_event(event_data))
    except (OSError, PermissionError) as e:
        print(f"Error reading {device_path}: {e}", file=sys.stderr)


async def main():
    """Monitor all input devices concurrently."""
    global _session, _hook_url

    # Load webhook URL from env file
    _hook_url = load_env()
    if _hook_url:
        print(f"Webhook enabled: {_hook_url}", file=sys.stderr)
    else:
        print("No webhook configured (keys.env not found or HOOK_URL not set)", file=sys.stderr)

    # Create HTTP session with maximum performance settings
    connector = aiohttp.TCPConnector(
        limit=1,                    # Single connection to one endpoint
        limit_per_host=1,
        ttl_dns_cache=300,          # Cache DNS for 5 minutes
        enable_cleanup_closed=True,
        force_close=False,          # Keep-alive for connection reuse
        keepalive_timeout=30,       # Keep connection alive for 30s
    )

    timeout = aiohttp.ClientTimeout(
        total=0.3,                  # 300ms total timeout (reduced)
        connect=0.1,                # 100ms connect timeout (reduced)
        sock_read=0.2,              # 200ms read timeout (reduced)
        sock_connect=0.1,           # 100ms socket connect (reduced)
    )

    _session = aiohttp.ClientSession(
        connector=connector,
        timeout=timeout,
        headers={                   # Minimal headers for speed
            'Connection': 'keep-alive',
            'Content-Type': 'application/json',
        },
        raise_for_status=False,     # Don't raise on HTTP errors
        auto_decompress=False,      # Skip decompression
        skip_auto_headers={'User-Agent'},  # Skip auto-added headers
        trust_env=False,            # Skip environment proxy checks
    )

    try:
        monitored = set()
        tasks = set()

        while True:
            devices = set(dev for dev in list_devices() if Path(dev).exists())

            if not devices and not monitored:
                print("No input devices found. May need root/input group access.", file=sys.stderr)
                await asyncio.sleep(1)
                continue

            # Start monitoring new devices
            for dev in devices - monitored:
                task = asyncio.create_task(monitor_device(dev))
                tasks.add(task)
                monitored.add(dev)

            # Remove disconnected devices
            monitored &= devices
            # pprint(monitored)

            await asyncio.sleep(1)
    finally:
        # Clean up session
        await _session.close()


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        pass
