# Installation Guide for EvdevRelay

## Build Requirements

### Required

1. **Go 1.21 or later**
   - Download from https://go.dev/dl/
   - Ubuntu/Debian: `sudo apt-get install golang`
   - Fedora/RHEL: `sudo dnf install golang`
   - Arch: `sudo pacman -S go`

2. **GCC (for CGO compilation)**
   - Ubuntu/Debian: `sudo apt-get install build-essential`
   - Fedora/RHEL: `sudo dnf install gcc`
   - Arch: `sudo pacman -S base-devel`

### Optional (for ARM cross-compilation)

3. **ARM Cross-Compiler** (needed to build ARM binaries on x86_64)
   - Ubuntu/Debian:
     ```bash
     sudo apt-get install gcc-arm-linux-gnueabihf gcc-aarch64-linux-gnu
     ```
   - Fedora/RHEL:
     ```bash
     sudo dnf install gcc-arm-linux-gnu gcc-aarch64-linux-gnu
     ```

**Note:** If you don't have ARM cross-compilers, you can:
- Build only the x86_64 version using `./build-x86_64.sh`
- Build the ARM version directly on a Raspberry Pi

## Quick Start

### Ubuntu/Debian

```bash
# Install all dependencies
sudo apt-get update
sudo apt-get install -y golang build-essential gcc-arm-linux-gnueabihf gcc-aarch64-linux-gnu

# Build all architectures
./build.sh

# Or build just x86_64
./build-x86_64.sh
```

### Fedora/RHEL

```bash
# Install all dependencies
sudo dnf install -y golang gcc gcc-arm-linux-gnu gcc-aarch64-linux-gnu

# Build all architectures
./build.sh
```

### Arch Linux

```bash
# Install dependencies
sudo pacman -S go base-devel arm-none-eabi-gcc

# Build all architectures
./build.sh
```

## Building on Raspberry Pi (Native Build)

If you're building directly on a Raspberry Pi:

```bash
# Install Go and build tools
sudo apt-get update
sudo apt-get install -y golang build-essential

# Build native binary (automatically detects architecture)
./build-x86_64.sh  # This will actually build for ARM when run on Pi
```

Or use the architecture-specific script:

```bash
# For Raspberry Pi Zero W
./build-arm.sh
```

## Cross-Compilation from x86_64 to ARM

The build scripts handle cross-compilation automatically:

```bash
# Build all architectures (x86_64 + all ARM variants)
./build.sh

# The script will:
# 1. Check for required tools
# 2. Download Go dependencies
# 3. Build x86_64 binary
# 4. Build ARM binaries if cross-compilers are available
# 5. Report which binaries were successfully built
```

## Troubleshooting

### "gcc not found"

You need to install build tools:
```bash
# Ubuntu/Debian
sudo apt-get install build-essential

# Fedora/RHEL
sudo dnf install gcc

# Arch
sudo pacman -S base-devel
```

### "arm-linux-gnueabihf-gcc not found"

This is only needed for cross-compiling to ARM from x86_64. You have two options:

**Option 1:** Install cross-compiler
```bash
sudo apt-get install gcc-arm-linux-gnueabihf gcc-aarch64-linux-gnu
```

**Option 2:** Build on the target device (Raspberry Pi)
- Copy the source code to your Raspberry Pi
- Run `./build-x86_64.sh` (it will build for ARM when run on Pi)

### "CGO_ENABLED=1 but gcc not available"

Install gcc:
```bash
sudo apt-get install build-essential
```

### Go module errors

If you get errors about missing modules:
```bash
go mod download
go mod tidy
```

Then run the build script again.

## Verifying the Build

After building, check the binaries:

```bash
ls -lh build/
```

You should see:
- `evdevrelay-linux-amd64` - x86_64 binary
- `evdevrelay-linux-arm6` - Raspberry Pi Zero W binary (if cross-compiled)
- `evdevrelay-linux-arm7` - Raspberry Pi 2/3/4 binary (if cross-compiled)
- `evdevrelay-linux-arm64` - Raspberry Pi 3/4/5 64-bit binary (if cross-compiled)

Test the binary:
```bash
# Check it runs
./build/evdevrelay-linux-amd64 --help || ./build/evdevrelay-linux-amd64

# Check dependencies (should show only libc)
ldd ./build/evdevrelay-linux-amd64
```

## Next Steps

After building, see the main README.md for:
- Running the application
- Configuration options
- Installing as a systemd service
- Testing with OSC servers
