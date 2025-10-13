# EvdevRelay

A robust Linux evdev to OSC relay written in Go. Monitors all evdev input devices and forwards their events to an OSC server with automatic reconnection and device hotplug support.

## Features

- **Automatic Device Discovery**: Automatically discovers and monitors all evdev input devices
- **Hotplug Support**: Detects when devices are added or removed
- **Automatic Reconnection**: Robust OSC connection management with automatic retry
- **Static Binaries**: Fully static binaries with no dependencies
- **Cross-Platform Builds**: Build for x86_64, ARM (Pi Zero W), ARM7, and ARM64
- **Environment Configuration**: All configuration through environment variables
- **Systemd Integration**: Includes service file for easy deployment

## Building

### Prerequisites

- Go 1.21 or later
- Make (optional, for using Makefile)

### Quick Build

Build all architectures:
```bash
./build.sh
```

Or use Make:
```bash
make build
```

### Architecture-Specific Builds

Build for x86_64:
```bash
./build-x86_64.sh
# or
make x86_64
```

Build for ARM (Raspberry Pi Zero W):
```bash
./build-arm.sh
# or
make arm
```

Build for ARM7 (Raspberry Pi 2/3/4):
```bash
make arm7
```

Build for ARM64 (Raspberry Pi 3/4/5 64-bit):
```bash
make arm64
```

### Build Output

Binaries are placed in the `build/` directory:
- `evdevrelay-linux-amd64` - x86_64
- `evdevrelay-linux-arm6` - Raspberry Pi Zero W (ARMv6)
- `evdevrelay-linux-arm7` - Raspberry Pi 2/3/4 (ARMv7)
- `evdevrelay-linux-arm64` - Raspberry Pi 3/4/5 64-bit (ARM64)

## Configuration

All configuration is done through environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `OSC_HOST` | `localhost` | OSC server hostname or IP address |
| `OSC_PORT` | `8000` | OSC server port |
| `RECONNECT_DELAY` | `5` | Delay in seconds between reconnection attempts |
| `SCAN_INTERVAL` | `5` | Interval in seconds to scan for new devices |

## Usage

### Help and Configuration

```bash
# Show help
./build/evdevrelay-linux-amd64 --help

# Show version
./build/evdevrelay-linux-amd64 --version

# Generate .env file from the binary
./build/evdevrelay-linux-amd64 --print-env > .env
```

### Using .env File (Recommended)

```bash
# Generate .env from binary
./build/evdevrelay-linux-amd64 --print-env > .env

# Or copy example
cp .env.example .env

# Edit with your settings
nano .env

# Run using the script (automatically loads .env)
./scripts/run-example.sh
```

### Basic Usage

```bash
# Set environment variables
export OSC_HOST=192.168.1.100
export OSC_PORT=8000

# Run the binary
./build/evdevrelay-linux-amd64
```

### One-liner

```bash
OSC_HOST=192.168.1.100 OSC_PORT=8000 ./build/evdevrelay-linux-amd64
```

## OSC Message Format

Events are sent as OSC messages with the following format:

```
Address: /evdev/{device}/{type}/{code}
Value: {event_value}
```

### Example

For a key press on `/dev/input/event0`:
```
/evdev/event0/1/28  1    (KEY_ENTER pressed)
/evdev/event0/1/28  0    (KEY_ENTER released)
```

Where:
- `event0` is the device name
- `1` is the event type (EV_KEY)
- `28` is the key code (KEY_ENTER)
- `1`/`0` is the value (pressed/released)

### Common Event Types

- `0` - EV_SYN (synchronization, filtered out)
- `1` - EV_KEY (keyboard/button events)
- `2` - EV_REL (relative axes, like mouse movement)
- `3` - EV_ABS (absolute axes, like touchscreen)

## Installation on Linux

### Manual Installation

1. Copy the appropriate binary to `/usr/local/bin/`:
   ```bash
   sudo cp build/evdevrelay-linux-amd64 /usr/local/bin/evdevrelay
   sudo chmod +x /usr/local/bin/evdevrelay
   ```

2. Edit the systemd service file `evdevrelay.service` with your OSC server details

3. Install and enable the service:
   ```bash
   sudo cp evdevrelay.service /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable evdevrelay
   sudo systemctl start evdevrelay
   ```

4. Check status:
   ```bash
   sudo systemctl status evdevrelay
   ```

5. View logs:
   ```bash
   sudo journalctl -u evdevrelay -f
   ```

## Installation on Raspberry Pi Zero W

1. Transfer the ARM binary to your Pi:
   ```bash
   scp build/evdevrelay-linux-arm6 pi@raspberrypi.local:/tmp/
   ```

2. On the Pi:
   ```bash
   sudo mv /tmp/evdevrelay-linux-arm6 /usr/local/bin/evdevrelay
   sudo chmod +x /usr/local/bin/evdevrelay
   ```

3. Create environment file:
   ```bash
   sudo nano /etc/evdevrelay.conf
   ```

   Add your configuration:
   ```
   OSC_HOST=192.168.1.100
   OSC_PORT=8000
   RECONNECT_DELAY=5
   SCAN_INTERVAL=5
   ```

4. Create/edit systemd service:
   ```bash
   sudo nano /etc/systemd/system/evdevrelay.service
   ```

   Update the service file to source the config:
   ```ini
   [Service]
   EnvironmentFile=/etc/evdevrelay.conf
   ExecStart=/usr/local/bin/evdevrelay
   ```

5. Enable and start:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable evdevrelay
   sudo systemctl start evdevrelay
   sudo systemctl status evdevrelay
   ```

## Permissions

The application needs permission to read from `/dev/input/event*` devices. **You must configure permissions before running the application**, or you'll get "permission denied" errors.

### Quick Setup (Recommended for most users)

**Add your user to the input group:**

```bash
# Add yourself to the input group
sudo usermod -a -G input $USER

# Verify you're in the group (after logging out/in)
groups | grep input

# IMPORTANT: You MUST log out and log back in for this to take effect!
# Or run: newgrp input
```

After adding yourself to the input group, you can run the application without sudo:
```bash
./build/evdevrelay-linux-amd64
```

### Alternative Options

1. **Run as root** (quick test, not recommended for production)
   ```bash
   sudo ./build/evdevrelay-linux-amd64
   ```

2. **Use udev rules** (most secure, fine-grained control)

   Create `/etc/udev/rules.d/99-input.rules`:
   ```
   KERNEL=="event*", SUBSYSTEM=="input", MODE="0660", GROUP="input"
   ```

   Then reload:
   ```bash
   sudo udevadm control --reload-rules
   sudo udevadm trigger
   ```

   And add your user to input group:
   ```bash
   sudo usermod -a -G input $USER
   ```

### Verifying Permissions

Check that you can read input devices:
```bash
# Check device permissions
ls -la /dev/input/event*

# Should show something like:
# crw-rw---- 1 root input 13, 64 Oct 13 17:00 /dev/input/event0

# Verify you're in the input group
groups | grep input

# Test reading from a device (press a key while this runs)
sudo cat /dev/input/event0 | hexdump -C
# Press Ctrl+C to stop
```

### For systemd Service

The included systemd service runs as root by default. If you want to run as a specific user:

1. Edit `evdevrelay.service`:
   ```ini
   [Service]
   User=youruser
   Group=input
   ```

2. Ensure the user is in the input group:
   ```bash
   sudo usermod -a -G input youruser
   ```

## Testing OSC Reception

You can test OSC reception using Python:

```python
from pythonosc import dispatcher, osc_server

def print_handler(unused_addr, args, *values):
    print(f"OSC: {unused_addr} = {values}")

dispatcher = dispatcher.Dispatcher()
dispatcher.map("/evdev/*", print_handler)

server = osc_server.ThreadingOSCUDPServer(("0.0.0.0", 8000), dispatcher)
print("Serving on {}".format(server.server_address))
server.serve_forever()
```

Or using Pure Data, Max/MSP, or any OSC-capable software.

## Troubleshooting

### Permission denied errors

If you see errors like:
```
Failed to open device /dev/input/event1: open /dev/input/event1: permission denied
```

**Solution:**
```bash
# Add yourself to the input group
sudo usermod -a -G input $USER

# Log out and log back in (REQUIRED!)
# Or start a new shell with the group active:
newgrp input
```

Then run the application again. See the **Permissions** section above for more details.

### No devices found
- Check permissions: `ls -la /dev/input/event*`
- Verify you're in the input group: `groups | grep input`
- Check if devices exist: `ls /dev/input/`

### Connection issues
- Verify OSC server is running and reachable
- Check firewall rules: `sudo ufw status`
- Test with: `nc -u <host> <port>`

### High CPU usage
- Increase `SCAN_INTERVAL` to reduce device scanning frequency
- Check for misbehaving input devices

### Logs
View detailed logs:
```bash
# If running as service
sudo journalctl -u evdevrelay -f

# If running manually
./evdevrelay  # Logs to stdout
```

## Architecture

The application consists of three main components:

1. **OSCClient**: Manages UDP connection to OSC server with automatic reconnection
2. **DeviceMonitor**: Scans for and monitors evdev devices
3. **Event Handler**: Reads events from devices and forwards to OSC

All components run concurrently using goroutines with proper synchronization.

## Dependencies

- `github.com/gvalkov/golang-evdev` - Linux evdev interface
- `github.com/hyperboria/go-osc` - OSC protocol implementation

## License

MIT License - Feel free to use and modify as needed.

## Contributing

Contributions welcome! Please test on both x86_64 and ARM platforms.

## Known Issues

- SYN events are filtered out (they're redundant synchronization markers)
- Device scanning is periodic, not inotify-based (for simplicity and reliability)
- UDP is lossy - if you need guaranteed delivery, consider implementing TCP OSC

## Future Enhancements

- [ ] TCP OSC support
- [ ] Device filtering by name/type
- [ ] Event filtering/transformation
- [ ] Metrics/monitoring endpoint
- [ ] Configuration file support (in addition to env vars)
