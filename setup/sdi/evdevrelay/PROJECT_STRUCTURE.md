# EvdevRelay Project Structure

## Directory Layout

```
evdevrelay/
├── src/                      # Go source code
│   ├── main.go              # Application entry point
│   ├── config.go            # Configuration management
│   ├── osc_client.go        # OSC client with auto-reconnection
│   ├── device_monitor.go    # Device discovery and monitoring
│   └── device_type.go       # Device type classification
│
├── scripts/                  # Build and development scripts
│   ├── build.sh             # Build all architectures
│   ├── build-x86_64.sh      # Build x86_64 only
│   ├── build-arm.sh         # Build ARM only
│   ├── run-example.sh       # Run with example config
│   ├── development.sh       # Auto-rebuild on file changes
│   └── Makefile             # Make targets
│
├── build/                    # Compiled binaries (generated)
│   ├── evdevrelay-linux-amd64
│   ├── evdevrelay-linux-arm6
│   ├── evdevrelay-linux-arm7
│   └── evdevrelay-linux-arm64
│
├── build.sh                  # Convenience wrapper for scripts/build.sh
├── dev.sh                    # Convenience wrapper for scripts/development.sh
│
├── go.mod                    # Go module definition
├── go.sum                    # Go dependencies checksums
│
├── README.md                 # User documentation
├── INSTALL.md                # Installation instructions
├── PROJECT_STRUCTURE.md      # This file
│
├── .env.example              # Example environment config
├── .gitignore                # Git ignore rules
│
├── evdevrelay.service        # Systemd service file
└── test-osc-server.py        # Test OSC receiver script
```

## Source Code Organization

### `src/main.go`
- Application entry point
- Orchestrates initialization
- ~45 lines, minimal logic

### `src/config.go`
- Environment variable parsing
- Configuration validation
- Default values

### `src/osc_client.go`
- UDP connection management
- Automatic reconnection logic
- Thread-safe OSC message sending

### `src/device_monitor.go`
- Device discovery and enumeration
- Hotplug detection
- Event reading and forwarding
- OSC path generation

### `src/device_type.go`
- Device capability analysis
- Device type classification (keyboard/mouse/touchpad/etc.)

## Build Scripts

All scripts work from any directory (CWD-independent).

### `build.sh` or `./scripts/build.sh`
- Builds all architectures (x86_64, ARM6, ARM7, ARM64)
- Checks for required tools
- Shows helpful error messages

### `build-x86_64.sh` or `./scripts/build-x86_64.sh`
- Builds x86_64 only
- Faster for local development

### `build-arm.sh` or `./scripts/build-arm.sh`
- Builds ARM6 (Raspberry Pi Zero W) only
- Requires cross-compiler

### `development.sh` or `./dev.sh`
- Watches `src/*.go` for changes
- Auto-rebuilds and restarts on save
- Requires: `inotify-tools`

### `run-example.sh` or `./scripts/run-example.sh`
- Auto-detects architecture
- Runs appropriate binary
- Configurable via environment variables

## Usage

### Build
```bash
./build.sh              # Build all architectures
./scripts/build-x86_64.sh  # Build x86_64 only
```

### Development
```bash
./dev.sh                # Auto-rebuild on file changes
```

### Run
```bash
./scripts/run-example.sh
# or with custom config:
OSC_HOST=192.168.1.100 OSC_PORT=9000 ./scripts/run-example.sh
```

## Design Principles

1. **Single Responsibility** - Each source file has one clear purpose
2. **CWD-Independent** - All scripts work from any directory
3. **Fail-Fast** - Scripts check requirements and fail with helpful messages
4. **Modular** - Components are loosely coupled and independently testable
5. **Developer-Friendly** - Convenience wrappers, auto-reload, clear structure

## Adding New Features

1. **New device type?** → Edit `src/device_type.go`
2. **New OSC format?** → Edit `src/device_monitor.go::handleEvent()`
3. **New config option?** → Edit `src/config.go`
4. **New build target?** → Add to `scripts/build.sh`

## Dependencies

- **github.com/gvalkov/golang-evdev** - Linux evdev interface (requires CGO)
- **github.com/hypebeast/go-osc** - OSC protocol implementation

## Build Requirements

- Go 1.21+
- GCC (for CGO)
- Optional: ARM cross-compilers for ARM builds
