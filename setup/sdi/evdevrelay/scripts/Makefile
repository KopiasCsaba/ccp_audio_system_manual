.PHONY: all build clean x86_64 arm arm7 arm64 deps

VERSION ?= 1.0.0
BUILD_DIR = build

all: build

deps:
	@echo "Downloading dependencies..."
	go mod download
	go mod tidy

build: deps
	@./build.sh

x86_64: deps
	@./build-x86_64.sh

arm: deps
	@./build-arm.sh

arm7: deps
	@echo "Building for ARM7 (Raspberry Pi 2/3/4)..."
	@mkdir -p $(BUILD_DIR)
	CGO_ENABLED=0 GOOS=linux GOARCH=arm GOARM=7 go build \
		-ldflags="-s -w -X main.Version=$(VERSION)" \
		-a \
		-installsuffix cgo \
		-o $(BUILD_DIR)/evdevrelay-linux-arm7 \
		.
	@ls -lh $(BUILD_DIR)/evdevrelay-linux-arm7

arm64: deps
	@echo "Building for ARM64 (Raspberry Pi 3/4/5 64-bit)..."
	@mkdir -p $(BUILD_DIR)
	CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build \
		-ldflags="-s -w -X main.Version=$(VERSION)" \
		-a \
		-installsuffix cgo \
		-o $(BUILD_DIR)/evdevrelay-linux-arm64 \
		.
	@ls -lh $(BUILD_DIR)/evdevrelay-linux-arm64

clean:
	@echo "Cleaning build artifacts..."
	rm -rf $(BUILD_DIR)
	@echo "✓ Clean complete"

install-deps:
	@echo "Installing Go dependencies..."
	go get github.com/gvalkov/golang-evdev
	go get github.com/hyperboria/go-osc/osc
	go mod tidy
