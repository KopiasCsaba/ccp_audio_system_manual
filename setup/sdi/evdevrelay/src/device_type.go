package main

import (
	evdev "github.com/gvalkov/golang-evdev"
)

// GetDeviceType determines device type based on capabilities
func GetDeviceType(device *evdev.InputDevice) string {
	caps := device.Capabilities

	hasKey := false
	hasRel := false
	hasAbs := false

	for evType := range caps {
		switch evType.Type {
		case evdev.EV_KEY:
			hasKey = true
		case evdev.EV_REL:
			hasRel = true
		case evdev.EV_ABS:
			hasAbs = true
		}
	}

	// Classify based on capability combinations
	if hasKey && hasRel {
		return "mouse"
	} else if hasKey && hasAbs {
		// Could be touchpad, touchscreen, or tablet
		// For simplicity, call it touchpad
		return "touchpad"
	} else if hasKey {
		return "keyboard"
	} else if hasAbs {
		return "joystick"
	} else if hasRel {
		return "trackball"
	}

	return "unknown"
}
