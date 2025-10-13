# EvdevRelay Quick Start

## 1. Setup

```bash
# Copy example config
cp .env.example .env

# Edit configuration
nano .env
```

Example `.env`:
```bash
OSC_HOST=192.168.1.100
OSC_PORT=8000
RECONNECT_DELAY=5
SCAN_INTERVAL=5
```

## 2. Build

```bash
./build.sh
```

Or for x86_64 only:
```bash
./scripts/build-x86_64.sh
```

## 3. Fix Permissions

```bash
# Add yourself to input group
sudo usermod -a -G input $USER

# Log out and log back in, or:
newgrp input
```

## 4. Run

```bash
./scripts/run-example.sh
```

The script will:
- Automatically load `.env` file
- Detect your architecture
- Run the appropriate binary

## 5. Development Mode

For auto-reload during development:

```bash
./dev.sh
```

This watches `src/*.go` files and automatically rebuilds/restarts on changes.

## Directory Structure

```
evdevrelay/
├── src/              # Go source files
├── scripts/          # Build & run scripts
├── build/            # Compiled binaries
├── .env             # Your config (not in git)
├── .env.example     # Config template
├── build.sh         # Wrapper for scripts/build.sh
└── dev.sh           # Wrapper for scripts/development.sh
```

## Common Commands

```bash
# Build all platforms
./build.sh

# Build x86_64 only
./scripts/build-x86_64.sh

# Run with .env
./scripts/run-example.sh

# Run with inline env vars
OSC_HOST=192.168.1.100 ./scripts/run-example.sh

# Development mode
./dev.sh
```

## Testing

Start OSC test server:
```bash
python3 test-osc-server.py 8000
```

In another terminal, run evdevrelay:
```bash
./scripts/run-example.sh
```

Press keys and see events in the test server output.

## Troubleshooting

**"Permission denied"**
```bash
sudo usermod -a -G input $USER
newgrp input
```

**"Binary not found"**
```bash
./build.sh
```

**"Go not found"**
```bash
sudo apt-get install golang
```

**"GCC not found"**
```bash
sudo apt-get install build-essential
```

For more details, see [README.md](README.md) and [INSTALL.md](INSTALL.md).
