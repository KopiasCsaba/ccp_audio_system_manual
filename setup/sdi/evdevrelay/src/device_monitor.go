package main

import (
	"fmt"
	"log"
	"path/filepath"
	"sync"
	"time"

	evdev "github.com/gvalkov/golang-evdev"
)

// DeviceMonitor monitors evdev devices and forwards events to OSC
type DeviceMonitor struct {
	config    *Config
	oscClient *OSCClient
	devices   map[string]*evdev.InputDevice
	devicesMu sync.RWMutex
	stopChan  chan struct{}
	wg        sync.WaitGroup
}

// NewDeviceMonitor creates a new device monitor
func NewDeviceMonitor(config *Config, oscClient *OSCClient) *DeviceMonitor {
	return &DeviceMonitor{
		config:    config,
		oscClient: oscClient,
		devices:   make(map[string]*evdev.InputDevice),
		stopChan:  make(chan struct{}),
	}
}

// Start begins monitoring devices
func (m *DeviceMonitor) Start() {
	// Initial scan
	m.scanDevices()

	// Periodic rescan to detect new devices
	go func() {
		ticker := time.NewTicker(m.config.ScanInterval)
		defer ticker.Stop()

		for {
			select {
			case <-ticker.C:
				m.scanDevices()
			case <-m.stopChan:
				return
			}
		}
	}()
}

// scanDevices scans for evdev devices and starts monitoring new ones
func (m *DeviceMonitor) scanDevices() {
	devices, err := filepath.Glob("/dev/input/event*")
	if err != nil {
		log.Printf("Error scanning for input devices: %v", err)
		return
	}

	m.devicesMu.Lock()
	defer m.devicesMu.Unlock()

	// Track which devices we've seen
	seen := make(map[string]bool)

	for _, devicePath := range devices {
		seen[devicePath] = true

		// Skip if we're already monitoring this device
		if _, exists := m.devices[devicePath]; exists {
			continue
		}

		// Try to open the device
		device, err := evdev.Open(devicePath)
		if err != nil {
			log.Printf("Failed to open device %s: %v", devicePath, err)
			continue
		}

		m.devices[devicePath] = device
		log.Printf("Started monitoring device: %s (Name: %s, Type: %s)",
			devicePath, device.Name, GetDeviceType(device))

		// Start monitoring this device
		m.wg.Add(1)
		go m.monitorDevice(devicePath, device)
	}

	// Remove devices that no longer exist
	for devicePath, device := range m.devices {
		if !seen[devicePath] {
			log.Printf("Device removed: %s", devicePath)
			device.File.Close()
			delete(m.devices, devicePath)
		}
	}
}

// monitorDevice monitors a single device and forwards events to OSC
func (m *DeviceMonitor) monitorDevice(devicePath string, device *evdev.InputDevice) {
	defer m.wg.Done()
	defer func() {
		if r := recover(); r != nil {
			log.Printf("Recovered from panic in device monitor for %s: %v", devicePath, r)
		}
	}()

	log.Printf("Monitoring device: %s", devicePath)

	for {
		select {
		case <-m.stopChan:
			return
		default:
			// Read events with timeout
			events, err := device.Read()
			if err != nil {
				log.Printf("Error reading from device %s: %v. Removing device.", devicePath, err)
				m.devicesMu.Lock()
				delete(m.devices, devicePath)
				device.File.Close()
				m.devicesMu.Unlock()
				return
			}

			for _, event := range events {
				m.handleEvent(devicePath, device, &event)
			}
		}
	}
}

// handleEvent processes an input event and sends it to OSC
func (m *DeviceMonitor) handleEvent(devicePath string, device *evdev.InputDevice, event *evdev.InputEvent) {
	// Skip synchronization events (they're generated after every event)
	if event.Type == evdev.EV_SYN {
		return
	}

	// Skip MSC_SCAN events (type 4, code 4)
	if event.Type == evdev.EV_MSC && event.Code == 4 {
		return
	}

	// Get device vendor and product IDs
	vendor := fmt.Sprintf("%04x", device.Vendor)
	product := fmt.Sprintf("%04x", device.Product)

	// Determine device type
	deviceType := GetDeviceType(device)

	// Build code identifier (name if available, otherwise number)
	codeStr := fmt.Sprintf("%d", event.Code)
	if event.Type == evdev.EV_KEY {
		if keyName := GetKeyName(event.Code); keyName != "" {
			codeStr = keyName
		}
	}

	// Send to three OSC paths (based on configuration):
	// 1. /merged/{device_type}/{code} with value
	if !m.config.DisableMerged {
		mergedPath := fmt.Sprintf("/merged/%s/%s", deviceType, codeStr)
		err := m.oscClient.SendMessage(mergedPath, int32(event.Value))
		if err != nil {
			log.Printf("Failed to send merged OSC message: %v", err)
		} else {
			log.Printf("Sent merged: %s = %d", mergedPath, event.Value)
		}
	}

	// 2. /merged/latest/* paths (most recent input from any device)
	if !m.config.DisableLatest {
		latestKeyPath := "/merged/latest/key"
		err := m.oscClient.SendMessage(latestKeyPath, codeStr)
		if err != nil {
			log.Printf("Failed to send latest key OSC message: %v", err)
		} else {
			log.Printf("Sent latest key: %s = %s", latestKeyPath, codeStr)
		}

		latestValuePath := "/merged/latest/value"
		err = m.oscClient.SendMessage(latestValuePath, int32(event.Value))
		if err != nil {
			log.Printf("Failed to send latest value OSC message: %v", err)
		} else {
			log.Printf("Sent latest value: %s = %d", latestValuePath, event.Value)
		}

		latestDevicePath := "/merged/latest/device"
		deviceID := fmt.Sprintf("%s:%s", vendor, product)
		err = m.oscClient.SendMessage(latestDevicePath, deviceID)
		if err != nil {
			log.Printf("Failed to send latest device OSC message: %v", err)
		} else {
			log.Printf("Sent latest device: %s = %s", latestDevicePath, deviceID)
		}
	}

	// 3. /{device_type}/{vendor}/{product}/{code} with value
	if !m.config.DisableByType {
		deviceSpecificPath := fmt.Sprintf("/%s/%s/%s/%s", deviceType, vendor, product, codeStr)
		err := m.oscClient.SendMessage(deviceSpecificPath, int32(event.Value))
		if err != nil {
			log.Printf("Failed to send device-specific OSC message: %v", err)
		} else {
			log.Printf("Sent device: %s = %d (device: %s, type: %s)",
				deviceSpecificPath, event.Value, device.Name, deviceType)
		}
	}
}

// Stop stops the device monitor
func (m *DeviceMonitor) Stop() {
	close(m.stopChan)
	m.wg.Wait()

	m.devicesMu.Lock()
	for _, device := range m.devices {
		device.File.Close()
	}
	m.devicesMu.Unlock()
}
