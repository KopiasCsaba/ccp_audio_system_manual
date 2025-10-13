package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"time"
)

const version = "1.0.0"

func printHelp() {
	fmt.Printf(`EvdevRelay v%s - Linux evdev to OSC relay

DESCRIPTION:
    EvdevRelay monitors Linux input devices (/dev/input/event*) and forwards
    their events to an OSC (Open Sound Control) server via UDP. It automatically
    detects devices, handles reconnections, and provides multiple OSC paths for
    flexibility in routing events.

USAGE:
    evdevrelay [OPTIONS]

OPTIONS:
    -h, --help          Show this help message
    --version           Show version information
    --print-env         Print example .env configuration and exit

CONFIGURATION:
    Configuration is done via environment variables. You can set them directly
    in your shell or create a .env file in the project directory.

%s
EXAMPLES:
    # Run with default configuration
    evdevrelay

    # Run with custom OSC server
    OSC_HOST=192.168.1.100 OSC_PORT=9000 evdevrelay

    # Generate example .env file
    evdevrelay --print-env > .env

    # Edit and use .env file
    cp .env.example .env
    nano .env
    evdevrelay

PERMISSIONS:
    You need read access to /dev/input/event* devices.
    Add yourself to the input group:
        sudo usermod -a -G input $USER
        newgrp input

OSC MESSAGE FORMATS:
    EvdevRelay sends events to three different OSC path formats (each can be
    disabled via configuration):

    1. Merged (all devices of same type):
       /merged/{device_type}/{key_name}
       Examples:
         /merged/keyboard/enter = 1
         /merged/mouse/btn_left = 1
         /merged/mouse/rel_x = -5

    2. Latest (most recent input from any device):
       /merged/latest/key    = "enter"     (key name as string)
       /merged/latest/value  = 1           (key value as integer)
       /merged/latest/device = "413c:2113" (vendor:product as string)

    3. Device-specific:
       /{device_type}/{vendor}/{product}/{key_name}
       Examples:
         /keyboard/413c/2113/space = 0
         /mouse/046d/c52b/btn_left = 1

    Values:
       Keys/Buttons: 0=released, 1=pressed, 2=held/repeat
       Mouse:        Signed integer delta (movement) or button state
`, version, GenerateEnvHelp())
}

func printEnv() {
	fmt.Print(GenerateEnvFile())
}

func main() {
	// Parse command line flags
	helpFlag := flag.Bool("help", false, "Show help message")
	helpFlagShort := flag.Bool("h", false, "Show help message")
	versionFlag := flag.Bool("version", false, "Show version")
	printEnvFlag := flag.Bool("print-env", false, "Print example .env configuration")

	flag.Parse()

	// Handle flags
	if *helpFlag || *helpFlagShort {
		printHelp()
		os.Exit(0)
	}

	if *versionFlag {
		fmt.Printf("EvdevRelay v%s\n", version)
		os.Exit(0)
	}

	if *printEnvFlag {
		printEnv()
		os.Exit(0)
	}

	// Normal operation
	log.SetOutput(os.Stdout)
	log.SetFlags(log.Ldate | log.Ltime | log.Lmicroseconds)

	log.Printf("EvdevRelay v%s - Linux evdev to OSC relay", version)
	log.Println("=============================================")
	log.Println()

	// Load configuration
	config, err := LoadConfig()
	if err != nil {
		log.Printf("Configuration error: %v", err)
		log.Println("\nTo see configuration options, run: evdevrelay --help")
		log.Println("To generate example .env file, run: evdevrelay --print-env > .env")
		os.Exit(1)
	}

	log.Printf("Configuration:")
	log.Printf("  OSC Host: %s", config.OSCHost)
	log.Printf("  OSC Port: %d", config.OSCPort)
	log.Printf("  Reconnect Delay: %v", config.ReconnectDelay)
	log.Printf("  Device Scan Interval: %v", config.ScanInterval)
	log.Printf("  Command Blocks:")
	log.Printf("    Merged: %v", !config.DisableMerged)
	log.Printf("    Latest: %v", !config.DisableLatest)
	log.Printf("    By Type: %v", !config.DisableByType)
	log.Println()

	// Create and start OSC client
	oscClient := NewOSCClient(config)
	oscClient.Start()

	// Wait for initial connection
	for !oscClient.IsConnected() {
		time.Sleep(100 * time.Millisecond)
	}

	// Create and start device monitor
	deviceMonitor := NewDeviceMonitor(config, oscClient)
	deviceMonitor.Start()

	log.Println("EvdevRelay is running. Press Ctrl+C to stop.")

	// Keep running until interrupted
	select {}
}
