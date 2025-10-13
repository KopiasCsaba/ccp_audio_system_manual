package main

import (
	"fmt"
	"log"
	"net"
	"sync"
	"time"

	"github.com/hypebeast/go-osc/osc"
)

// OSCClient manages the connection to the OSC server with automatic reconnection
type OSCClient struct {
	config        *Config
	conn          net.Conn
	mu            sync.RWMutex
	connected     bool
	stopChan      chan struct{}
	reconnectChan chan struct{}
}

// NewOSCClient creates a new OSC client
func NewOSCClient(config *Config) *OSCClient {
	return &OSCClient{
		config:        config,
		connected:     false,
		stopChan:      make(chan struct{}),
		reconnectChan: make(chan struct{}, 1),
	}
}

// Start begins the connection management goroutine
func (c *OSCClient) Start() {
	go c.connectionManager()
}

// connectionManager handles connecting and reconnecting to the OSC server
func (c *OSCClient) connectionManager() {
	for {
		select {
		case <-c.stopChan:
			log.Println("OSC connection manager stopping")
			return
		default:
			c.connect()
			// Wait for reconnect signal or stop signal
			select {
			case <-c.reconnectChan:
				log.Println("Reconnection requested")
			case <-c.stopChan:
				log.Println("OSC connection manager stopping")
				return
			}
		}
	}
}

// connect attempts to connect to the OSC server with retry logic
func (c *OSCClient) connect() {
	address := fmt.Sprintf("%s:%d", c.config.OSCHost, c.config.OSCPort)

	for {
		select {
		case <-c.stopChan:
			return
		default:
			log.Printf("Attempting to connect to OSC server at %s...", address)
			conn, err := net.DialTimeout("udp", address, 5*time.Second)
			if err != nil {
				log.Printf("Failed to connect to OSC server: %v. Retrying in %v...", err, c.config.ReconnectDelay)
				time.Sleep(c.config.ReconnectDelay)
				continue
			}

			c.mu.Lock()
			c.conn = conn
			c.connected = true
			c.mu.Unlock()

			log.Printf("Successfully connected to OSC server at %s", address)
			return
		}
	}
}

// SendMessage sends an OSC message, triggering reconnection if the connection is lost
func (c *OSCClient) SendMessage(address string, args ...interface{}) error {
	c.mu.RLock()
	if !c.connected || c.conn == nil {
		c.mu.RUnlock()
		return fmt.Errorf("not connected to OSC server")
	}
	conn := c.conn
	c.mu.RUnlock()

	msg := osc.NewMessage(address)
	for _, arg := range args {
		msg.Append(arg)
	}

	packet, err := msg.MarshalBinary()
	if err != nil {
		return fmt.Errorf("failed to marshal OSC message: %v", err)
	}

	_, err = conn.Write(packet)
	if err != nil {
		log.Printf("Failed to send OSC message: %v. Triggering reconnection...", err)
		c.mu.Lock()
		c.connected = false
		if c.conn != nil {
			c.conn.Close()
			c.conn = nil
		}
		c.mu.Unlock()

		// Trigger reconnection (non-blocking)
		select {
		case c.reconnectChan <- struct{}{}:
		default:
		}

		return err
	}

	return nil
}

// IsConnected returns whether the client is currently connected
func (c *OSCClient) IsConnected() bool {
	c.mu.RLock()
	defer c.mu.RUnlock()
	return c.connected
}

// Stop stops the OSC client
func (c *OSCClient) Stop() {
	close(c.stopChan)
	c.mu.Lock()
	if c.conn != nil {
		c.conn.Close()
	}
	c.mu.Unlock()
}
