package main

import (
	"fmt"
	"os"
	"reflect"
	"strconv"
	"strings"
	"time"
)

// ConfigVarType represents the type of a configuration variable
type ConfigVarType int

const (
	TypeString ConfigVarType = iota
	TypeInt
	TypeBool
)

// ConfigVarDef defines a configuration variable with its metadata
type ConfigVarDef struct {
	Name        string                            // Environment variable name
	Type        ConfigVarType                     // Variable type
	Default     string                            // Default value as string
	Description string                            // Description for help text
	Group       string                            // Configuration group for organization
	Validator   func(string) (interface{}, error) // Optional validator function
	ConfigField string                            // Field name in Config struct for automatic mapping
}

// configDefinitions defines all configuration variables declaratively
var configDefinitions = []ConfigVarDef{
	{
		Name:        "OSC_HOST",
		Type:        TypeString,
		Default:     "localhost",
		Description: "OSC server hostname or IP address",
		Group:       "OSC Server",
		ConfigField: "OSCHost",
		Validator:   nil, // No validation needed for hostname
	},
	{
		Name:        "OSC_PORT",
		Type:        TypeInt,
		Default:     "8000",
		Description: "OSC server port (1-65535)",
		Group:       "OSC Server",
		ConfigField: "OSCPort",
		Validator: func(value string) (interface{}, error) {
			port, err := strconv.Atoi(value)
			if err != nil {
				return nil, fmt.Errorf("invalid OSC_PORT '%s': must be a number between 1-65535", value)
			}
			if port < 1 || port > 65535 {
				return nil, fmt.Errorf("invalid OSC_PORT %d: must be between 1-65535", port)
			}
			return port, nil
		},
	},
	{
		Name:        "RECONNECT_DELAY",
		Type:        TypeInt,
		Default:     "5",
		Description: "Seconds between reconnection attempts",
		Group:       "Connection",
		ConfigField: "ReconnectDelay",
		Validator: func(value string) (interface{}, error) {
			seconds, err := strconv.Atoi(value)
			if err != nil {
				return nil, fmt.Errorf("invalid RECONNECT_DELAY '%s': must be a positive number", value)
			}
			if seconds < 1 {
				return nil, fmt.Errorf("invalid RECONNECT_DELAY %d: must be at least 1 second", seconds)
			}
			return time.Duration(seconds) * time.Second, nil
		},
	},
	{
		Name:        "SCAN_INTERVAL",
		Type:        TypeInt,
		Default:     "5",
		Description: "Seconds between device scans",
		Group:       "Connection",
		ConfigField: "ScanInterval",
		Validator: func(value string) (interface{}, error) {
			seconds, err := strconv.Atoi(value)
			if err != nil {
				return nil, fmt.Errorf("invalid SCAN_INTERVAL '%s': must be a positive number", value)
			}
			if seconds < 1 {
				return nil, fmt.Errorf("invalid SCAN_INTERVAL %d: must be at least 1 second", seconds)
			}
			return time.Duration(seconds) * time.Second, nil
		},
	},
	{
		Name:        "DISABLE_MERGED",
		Type:        TypeBool,
		Default:     "false",
		Description: "Disable /merged/{device_type}/{code} messages",
		Group:       "Command Blocks",
		ConfigField: "DisableMerged",
		Validator:   nil, // Uses default bool parser
	},
	{
		Name:        "DISABLE_LATEST",
		Type:        TypeBool,
		Default:     "false",
		Description: "Disable /merged/latest/* messages (key, value, device)",
		Group:       "Command Blocks",
		ConfigField: "DisableLatest",
		Validator:   nil, // Uses default bool parser
	},
	{
		Name:        "DISABLE_BY_TYPE",
		Type:        TypeBool,
		Default:     "false",
		Description: "Disable /{device_type}/{vendor}/{product}/{code} messages",
		Group:       "Command Blocks",
		ConfigField: "DisableByType",
		Validator:   nil, // Uses default bool parser
	},
}

// Config holds application configuration from environment variables
type Config struct {
	OSCHost        string
	OSCPort        int
	ReconnectDelay time.Duration
	ScanInterval   time.Duration
	DisableMerged  bool
	DisableLatest  bool
	DisableByType  bool
}

// LoadConfig loads configuration from environment variables with validation
// This function automatically parses all values from configDefinitions
func LoadConfig() (*Config, error) {
	config := &Config{}
	configValue := reflect.ValueOf(config).Elem()

	// Iterate through all config definitions and parse each one
	for _, def := range configDefinitions {
		// Get value from environment or use default
		value := os.Getenv(def.Name)
		if value == "" {
			value = def.Default
		}

		// Parse the value based on type
		var parsedValue interface{}
		var err error

		// Use custom validator if provided, otherwise use default parsers
		if def.Validator != nil {
			parsedValue, err = def.Validator(value)
			if err != nil {
				return nil, err
			}
		} else {
			// Default parsing based on type
			switch def.Type {
			case TypeString:
				parsedValue = value
			case TypeInt:
				parsedValue, err = strconv.Atoi(value)
				if err != nil {
					return nil, fmt.Errorf("invalid %s '%s': must be a number", def.Name, value)
				}
			case TypeBool:
				parsedValue = parseBool(value)
			default:
				return nil, fmt.Errorf("unsupported type for %s", def.Name)
			}
		}

		// Set the field in the config struct using reflection
		field := configValue.FieldByName(def.ConfigField)
		if !field.IsValid() {
			return nil, fmt.Errorf("config field %s not found for %s", def.ConfigField, def.Name)
		}
		if !field.CanSet() {
			return nil, fmt.Errorf("cannot set config field %s", def.ConfigField)
		}

		// Set the value with appropriate type conversion
		fieldValue := reflect.ValueOf(parsedValue)
		if fieldValue.Type().AssignableTo(field.Type()) {
			field.Set(fieldValue)
		} else {
			return nil, fmt.Errorf("type mismatch for %s: cannot assign %v to %v",
				def.ConfigField, fieldValue.Type(), field.Type())
		}
	}

	return config, nil
}

// parseBool parses a boolean value from a string
// Accepts: "true", "1", "yes", "on" (case-insensitive) as true
// Accepts: "false", "0", "no", "off", "" (case-insensitive) as false
func parseBool(value string) bool {
	switch value {
	case "true", "1", "yes", "on", "True", "TRUE", "Yes", "YES", "On", "ON":
		return true
	default:
		return false
	}
}

// GenerateEnvHelp generates help text for configuration from definitions
func GenerateEnvHelp() string {
	var sb strings.Builder

	// Group variables by their group
	groups := make(map[string][]ConfigVarDef)
	for _, def := range configDefinitions {
		groups[def.Group] = append(groups[def.Group], def)
	}

	// Define group order
	groupOrder := []string{"OSC Server", "Connection", "Command Blocks"}

	for _, groupName := range groupOrder {
		defs, exists := groups[groupName]
		if !exists {
			continue
		}

		sb.WriteString(fmt.Sprintf("    %s:\n", groupName))
		for _, def := range defs {
			var typeStr string
			switch def.Type {
			case TypeString:
				typeStr = "string"
			case TypeInt:
				typeStr = "number"
			case TypeBool:
				typeStr = "boolean"
			}

			sb.WriteString(fmt.Sprintf("      %-20s %s (type: %s, default: %s)\n",
				def.Name, def.Description, typeStr, def.Default))
		}
		sb.WriteString("\n")
	}

	// Add boolean value format note
	sb.WriteString("    Boolean values: true/false, 1/0, yes/no, on/off (case-insensitive)\n")

	return sb.String()
}

// GenerateEnvFile generates an example .env file from definitions
func GenerateEnvFile() string {
	var sb strings.Builder

	sb.WriteString("# EvdevRelay Configuration\n")
	sb.WriteString("# Save this as .env in the project root\n\n")

	// Group variables by their group
	groups := make(map[string][]ConfigVarDef)
	for _, def := range configDefinitions {
		groups[def.Group] = append(groups[def.Group], def)
	}

	// Define group order
	groupOrder := []string{"OSC Server", "Connection", "Command Blocks"}

	for _, groupName := range groupOrder {
		defs, exists := groups[groupName]
		if !exists {
			continue
		}

		sb.WriteString(fmt.Sprintf("# %s\n", groupName))
		for _, def := range defs {
			sb.WriteString(fmt.Sprintf("%-20s  # %s\n",
				fmt.Sprintf("%s=%s", def.Name, def.Default), def.Description))
		}
		sb.WriteString("\n")
	}

	return sb.String()
}
