#!/usr/bin/env python3
"""HTTP server that forwards URL navigation commands to Brave browser via Chrome DevTools Protocol"""

import json
import socket
import base64
from urllib.parse import urlparse, parse_qs
from urllib.request import urlopen
from http.server import HTTPServer, BaseHTTPRequestHandler

BROWSER_PORT = 9222
BROWSER_HOST = "127.0.0.1"
SERVER_PORT = 9393


def get_browser_tabs():
    """Get list of browser tabs from Chrome DevTools Protocol"""
    try:
        with urlopen(f"http://{BROWSER_HOST}:{BROWSER_PORT}/json", timeout=5) as response:
            tabs = json.loads(response.read())
            return tabs
    except Exception as e:
        return None


def get_current_url():
    """Get the current URL from the first browser tab"""
    tabs = get_browser_tabs()
    if not tabs:
        return None, "No browser tabs found"

    # Return the URL from the first tab
    current_url = tabs[0].get("url", "")
    return current_url, None


def navigate_browser(target_url):
    """Navigate the current browser tab to the specified URL"""

    # Get first tab's WebSocket URL
    tabs = get_browser_tabs()
    if not tabs:
        return False, "No browser tabs found"

    try:
        ws_url = tabs[0]["webSocketDebuggerUrl"]
    except Exception as e:
        return False, f"Could not get WebSocket URL: {e}"

    # Parse WebSocket URL
    parsed = urlparse(ws_url)
    host, port = parsed.hostname, parsed.port or 80
    path = parsed.path + (f"?{parsed.query}" if parsed.query else "")

    # Connect and WebSocket handshake
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(3)
        sock.connect((host, port))

        key = base64.b64encode(b"cdp-key").decode()
        handshake = (
            f"GET {path} HTTP/1.1\r\n"
            f"Host: {host}:{port}\r\n"
            f"Upgrade: websocket\r\n"
            f"Connection: Upgrade\r\n"
            f"Sec-WebSocket-Key: {key}\r\n"
            f"Sec-WebSocket-Version: 13\r\n\r\n"
        )
        sock.sendall(handshake.encode())

        if b"101" not in sock.recv(4096):
            sock.close()
            return False, "WebSocket handshake failed"

        # Send navigate command
        cmd = json.dumps({
            "id": 1,
            "method": "Page.navigate",
            "params": {"url": target_url}
        }).encode()

        # Build WebSocket frame with proper length encoding
        # First byte: 0x81 (FIN=1, opcode=1 for text frame)
        # Second byte: 0x80 (MASK=1) | payload length
        frame = bytearray([0x81])

        payload_len = len(cmd)
        if payload_len <= 125:
            frame.append(0x80 | payload_len)
        elif payload_len <= 65535:
            frame.append(0x80 | 126)
            frame.extend(payload_len.to_bytes(2, byteorder='big'))
        else:
            frame.append(0x80 | 127)
            frame.extend(payload_len.to_bytes(8, byteorder='big'))

        # Masking key (all zeros for simplicity)
        frame.extend(b"\x00\x00\x00\x00")
        # Payload (no masking needed since key is all zeros)
        frame.extend(cmd)

        sock.sendall(frame)
        sock.close()

        return True, f"Navigated to: {target_url}"

    except Exception as e:
        return False, f"WebSocket communication error: {e}"


class BrowserControlHandler(BaseHTTPRequestHandler):
    """HTTP request handler for browser navigation commands"""

    def log_message(self, format, *args):
        """Log requests to stdout"""
        print(f"[{self.log_date_time_string()}] {format % args}")

    def do_POST(self):
        """Handle POST requests with URL parameter"""
        try:
            # Parse query parameters from path using standard library
            parsed_path = urlparse(self.path)
            params = parse_qs(parsed_path.query)

            # Get URL from query parameter
            if 'url' not in params or not params['url']:
                self.send_error(400, "Missing 'url' parameter")
                return

            target_url = params['url'][0]

            # Log the extracted URL for debugging
            print(f"[{self.log_date_time_string()}] Extracted URL: {target_url}")

            # Navigate browser
            success, message = navigate_browser(target_url)

            # Send response
            if success:
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                response = {
                    "status": "success",
                    "message": message,
                    "url": target_url
                }
                self.wfile.write(json.dumps(response).encode())
            else:
                self.send_response(500)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                response = {
                    "status": "error",
                    "message": message
                }
                self.wfile.write(json.dumps(response).encode())

        except Exception as e:
            self.send_error(500, f"Server error: {e}")

    def do_GET(self):
        """Handle GET requests - return current URL or navigate if url param provided"""
        try:
            # Parse query parameters from path
            parsed_path = urlparse(self.path)
            params = parse_qs(parsed_path.query)

            # If URL parameter provided, navigate (same as POST)
            if 'url' in params and params['url']:
                self.do_POST()
                return

            # Otherwise, return current URL
            current_url, error = get_current_url()

            if error:
                self.send_response(500)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                response = {
                    "status": "error",
                    "message": error
                }
                self.wfile.write(json.dumps(response).encode())
            else:
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                response = {
                    "status": "success",
                    "url": current_url
                }
                self.wfile.write(json.dumps(response).encode())

        except Exception as e:
            self.send_error(500, f"Server error: {e}")


def main():
    """Start the HTTP server"""
    server_address = ('', SERVER_PORT)
    httpd = HTTPServer(server_address, BrowserControlHandler)

    print(f"Browser HTTP control server starting on port {SERVER_PORT}")
    print(f"Forwarding to browser at {BROWSER_HOST}:{BROWSER_PORT}")
    print()
    print("Usage:")
    print(f"  Navigate: POST http://localhost:{SERVER_PORT}/?url=<target_url>")
    print(f"  Get URL:  GET  http://localhost:{SERVER_PORT}/")
    print()
    print("Examples:")
    print(f"  # Navigate to a URL")
    print(f"  curl -X POST 'http://localhost:{SERVER_PORT}/?url=https://example.com'")
    print(f"  curl -X POST 'http://localhost:{SERVER_PORT}/?url=file:///config/media/foo.html'")
    print()
    print(f"  # Get current URL")
    print(f"  curl http://localhost:{SERVER_PORT}/")
    print()

    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down server...")
        httpd.shutdown()


if __name__ == "__main__":
    main()
