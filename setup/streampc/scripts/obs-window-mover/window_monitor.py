"""
Window Monitor - Automatically moves windows to specific monitors by position
Monitors for window titles and moves them to designated monitors by X position.
"""

import win32gui
import win32con
import win32api
import time
from typing import Optional, Tuple, Dict, List

# Import configuration
from config import WINDOW_RULES, CHECK_INTERVAL, NOT_FOUND_CALLBACK_INTERVAL


class WindowMonitor:
    def __init__(self, window_rules: Dict, check_interval: float = 1.0, not_found_interval: float = 10.0):
        """
        Initialize the window monitor.
        
        Args:
            window_rules: Dictionary mapping window titles to monitor configs
            check_interval: How often to check for the window (in seconds)
            not_found_interval: How often to call on_not_found callbacks (in seconds)
        """
        self.window_rules = {}
        for window_title, config in window_rules.items():
            self.window_rules[window_title] = {
                "monitor": config.get("monitor", ""),
                "fullscreen": config.get("fullscreen", False),
                "move_once": config.get("move_once", False),
                "on_not_found": config.get("on_not_found", None)
            }
        
        self.check_interval = check_interval
        self.not_found_interval = not_found_interval
        self.moved_windows = {}  # Track windows: {hwnd: {"rule": "title", "moved": True/False}}
        self.last_not_found_call = {}  # Track last time on_not_found was called for each rule
    
    def get_monitor_info(self) -> list:
        """Get information about all connected monitors."""
        monitors = []
        
        def callback(hMonitor, hdcMonitor, lprcMonitor, dwData):
            import ctypes
            from ctypes import wintypes
            
            class MONITORINFOEXW(ctypes.Structure):
                _fields_ = [
                    ("cbSize", wintypes.DWORD),
                    ("rcMonitor", wintypes.RECT),
                    ("rcWork", wintypes.RECT),
                    ("dwFlags", wintypes.DWORD),
                    ("szDevice", wintypes.WCHAR * 32)
                ]
            
            info = MONITORINFOEXW()
            info.cbSize = ctypes.sizeof(MONITORINFOEXW)
            
            user32 = ctypes.windll.user32
            if user32.GetMonitorInfoW(hMonitor, ctypes.byref(info)):
                device_name = info.szDevice
                
                try:
                    display_device = win32api.EnumDisplayDevices(device_name, 0)
                    if display_device:
                        friendly_name = display_device.DeviceString
                    else:
                        friendly_name = "Unknown Monitor"
                except:
                    friendly_name = "Unknown Monitor"
                
                monitors.append({
                    'handle': hMonitor,
                    'device_name': device_name,
                    'friendly_name': friendly_name,
                    'left': lprcMonitor[0],
                    'top': lprcMonitor[1],
                    'right': lprcMonitor[2],
                    'bottom': lprcMonitor[3],
                    'width': lprcMonitor[2] - lprcMonitor[0],
                    'height': lprcMonitor[3] - lprcMonitor[1]
                })
            return True
        
        import ctypes
        user32 = ctypes.windll.user32
        user32.EnumDisplayMonitors(None, None, 
                                   ctypes.WINFUNCTYPE(ctypes.c_int, 
                                                     ctypes.c_ulong, 
                                                     ctypes.c_ulong, 
                                                     ctypes.POINTER(ctypes.c_long), 
                                                     ctypes.c_double)(callback), 
                                   0)
        
        monitors.sort(key=lambda m: m['left'])
        return monitors
    
    def find_windows(self) -> List[Tuple[int, str]]:
        """Find all windows matching any of the configured titles."""
        found_windows = []
        
        def callback(hwnd, extra):
            if win32gui.IsWindowVisible(hwnd):
                window_text = win32gui.GetWindowText(hwnd)
                for title_pattern in self.window_rules.keys():
                    if title_pattern.lower() in window_text.lower():
                        found_windows.append((hwnd, title_pattern))
                        break
            return True
        
        win32gui.EnumWindows(callback, None)
        return found_windows
    
    def find_monitor_by_position(self, position_str: str) -> Optional[dict]:
        """
        Find a monitor by its X position.
        
        Args:
            position_str: Position string like "pos:3200"
            
        Returns:
            Monitor dictionary if found, None otherwise
        """
        monitors = self.get_monitor_info()
        
        # Extract X position from "pos:3200" format
        if position_str.startswith('pos:'):
            x_str = position_str[4:].strip()
            try:
                target_x = int(x_str)
                # Find monitor at this X position
                for monitor in monitors:
                    if monitor['left'] == target_x:
                        return monitor
            except ValueError:
                pass
        
        return None
    
    def is_window_on_correct_monitor(self, hwnd: int, monitor: dict, fullscreen: bool) -> bool:
        """
        Check if a window is already on the correct monitor and in the correct state.
        
        Args:
            hwnd: Window handle
            monitor: Target monitor dictionary
            fullscreen: Whether window should be maximized
            
        Returns:
            True if window is already correctly positioned, False otherwise
        """
        try:
            rect = win32gui.GetWindowRect(hwnd)
            window_left = rect[0]
            window_top = rect[1]
            window_right = rect[2]
            window_bottom = rect[3]
            
            # Check if window is on the target monitor
            window_center_x = (window_left + window_right) // 2
            window_center_y = (window_top + window_bottom) // 2
            
            monitor_contains_window = (
                monitor['left'] <= window_center_x < monitor['right'] and
                monitor['top'] <= window_center_y < monitor['bottom']
            )
            
            if not monitor_contains_window:
                return False
            
            # If fullscreen is required, check if window is maximized
            if fullscreen:
                placement = win32gui.GetWindowPlacement(hwnd)
                is_maximized = placement[1] == win32con.SW_SHOWMAXIMIZED
                return is_maximized
            
            return True
            
        except Exception:
            return False
    
    def move_window_to_monitor(self, hwnd: int, monitor: dict, fullscreen: bool = False) -> bool:
        """
        Move a window to the specified monitor, optionally maximizing it.
        
        Args:
            hwnd: Window handle
            monitor: Monitor dictionary
            fullscreen: If True, maximize the window on the target monitor
            
        Returns:
            True if successful, False otherwise
        """
        try:
            placement = win32gui.GetWindowPlacement(hwnd)
            
            # Restore window if minimized
            if placement[1] == win32con.SW_SHOWMINIMIZED:
                win32gui.ShowWindow(hwnd, win32con.SW_RESTORE)
                time.sleep(0.1)
            
            if fullscreen:
                # Restore if already maximized
                if placement[1] == win32con.SW_SHOWMAXIMIZED:
                    win32gui.ShowWindow(hwnd, win32con.SW_RESTORE)
                    time.sleep(0.1)
                
                # Move window to target monitor
                win32gui.SetWindowPos(
                    hwnd,
                    win32con.HWND_TOP,
                    monitor['left'] + 100,
                    monitor['top'] + 100,
                    monitor['width'] - 200,
                    monitor['height'] - 200,
                    win32con.SWP_SHOWWINDOW | win32con.SWP_NOACTIVATE
                )
                time.sleep(0.1)
                
                # Maximize
                win32gui.ShowWindow(hwnd, win32con.SW_MAXIMIZE)
            else:
                # Just move and center
                rect = win32gui.GetWindowRect(hwnd)
                window_width = rect[2] - rect[0]
                window_height = rect[3] - rect[1]
                
                new_x = monitor['left'] + (monitor['width'] - window_width) // 2
                new_y = monitor['top'] + (monitor['height'] - window_height) // 2
                
                win32gui.SetWindowPos(
                    hwnd,
                    win32con.HWND_TOP,
                    new_x,
                    new_y,
                    window_width,
                    window_height,
                    win32con.SWP_SHOWWINDOW | win32con.SWP_NOACTIVATE
                )
            
            return True
        except Exception as e:
            print(f"Error moving window: {e}")
            return False
    
    def run(self):
        """Main monitoring loop."""
        print("Window Monitor - Mapping windows to monitors")
        print("=" * 70)
        
        # Display available monitors
        monitors = self.get_monitor_info()
        print(f"\nFound {len(monitors)} monitor(s):")
        for i, monitor in enumerate(monitors):
            print(f"  Monitor {i + 1}:")
            print(f"    Device: {monitor['device_name']}")
            print(f"    Name: {monitor['friendly_name']}")
            print(f"    Resolution: {monitor['width']}x{monitor['height']}")
            print(f"    Position: ({monitor['left']}, {monitor['top']})")
        
        # Display configured rules
        print(f"\nConfigured rules:")
        for window_title, config in self.window_rules.items():
            monitor_id = config["monitor"]
            fullscreen = config["fullscreen"]
            move_once = config["move_once"]
            has_callback = config["on_not_found"] is not None
            monitor = self.find_monitor_by_position(monitor_id)
            
            fullscreen_text = " [FULLSCREEN]" if fullscreen else ""
            move_once_text = " [MOVE ONCE]" if move_once else " [KEEP ON SCREEN]"
            callback_text = " [AUTO-OPEN]" if has_callback else ""
            
            if monitor:
                print(f"  ✓ '{window_title}' → {monitor['friendly_name']}{fullscreen_text}{move_once_text}{callback_text}")
            else:
                print(f"  ✗ '{window_title}' → '{monitor_id}'{fullscreen_text}{move_once_text}{callback_text} (MONITOR NOT FOUND)")
        
        print(f"\nMonitoring interval: {self.check_interval} seconds")
        print(f"Press Ctrl+C to stop monitoring.\n")
        
        iteration_count = 0
        try:
            while True:
                # Clean up tracking for windows that no longer exist
                windows_to_remove = []
                for hwnd in list(self.moved_windows.keys()):
                    if not win32gui.IsWindow(hwnd):
                        windows_to_remove.append(hwnd)
                
                for hwnd in windows_to_remove:
                    rule = self.moved_windows[hwnd]["rule"]
                    print(f"[Info] Window closed: '{rule}' - will track again if reopened")
                    del self.moved_windows[hwnd]
                
                # Find matching windows
                windows = self.find_windows()
                found_rules = set(title_pattern for _, title_pattern in windows)
                
                # Check for windows that are NOT found and have callbacks
                current_time = time.time()
                for rule_name, config in self.window_rules.items():
                    if rule_name not in found_rules and config["on_not_found"] is not None:
                        last_call = self.last_not_found_call.get(rule_name, 0)
                        
                        if current_time - last_call >= self.not_found_interval:
                            print(f"[Not Found] Window '{rule_name}' not detected")
                            print(f"  Calling on_not_found callback...")
                            
                            try:
                                success = config["on_not_found"]()
                                if success:
                                    self.last_not_found_call[rule_name] = current_time
                                    time.sleep(2)
                            except Exception as e:
                                print(f"  Error in callback: {e}")
                                self.last_not_found_call[rule_name] = current_time
                
                # Show status every 60 iterations
                iteration_count += 1
                if iteration_count % 60 == 0:
                    print(f"[Status] Monitoring active... ({iteration_count} checks completed, tracking {len(self.moved_windows)} window(s))")
                
                for hwnd, title_pattern in windows:
                    config = self.window_rules[title_pattern]
                    move_once = config["move_once"]
                    target_device = config["monitor"]
                    fullscreen = config["fullscreen"]
                    
                    # Check if we should skip this window
                    if hwnd in self.moved_windows:
                        if move_once and self.moved_windows[hwnd]["moved"]:
                            continue
                    
                    # Check if window is already in the correct position
                    monitor = self.find_monitor_by_position(target_device)
                    if monitor and self.is_window_on_correct_monitor(hwnd, monitor, fullscreen):
                        if hwnd not in self.moved_windows:
                            self.moved_windows[hwnd] = {
                                "rule": title_pattern,
                                "moved": True
                            }
                        continue
                    
                    # Window needs to be moved
                    window_title = win32gui.GetWindowText(hwnd)
                    
                    print(f"Found window: '{window_title}'")
                    print(f"  Matched rule: '{title_pattern}'")
                    print(f"  Target device: '{target_device}'")
                    if fullscreen:
                        print(f"  Mode: FULLSCREEN (maximize)")
                    if move_once:
                        print(f"  Move once: Will only move this window once")
                    else:
                        print(f"  Keep on screen: Will move back if window is moved away")
                    
                    if monitor:
                        action = "Maximizing on" if fullscreen else "Moving to"
                        print(f"  {action}: {monitor['friendly_name']}...")
                        
                        if self.move_window_to_monitor(hwnd, monitor, fullscreen):
                            print(f"  ✓ Successfully {'maximized' if fullscreen else 'moved'}\n")
                            self.moved_windows[hwnd] = {
                                "rule": title_pattern,
                                "moved": True
                            }
                        else:
                            print(f"  ✗ Failed to {'maximize' if fullscreen else 'move'} window\n")
                    else:
                        print(f"  ✗ Monitor '{target_device}' not found\n")
                
                time.sleep(self.check_interval)
                
        except KeyboardInterrupt:
            print("\n\nMonitoring stopped.")


def main():
    """Main function - Configuration is in config.py"""
    print("=" * 70)
    print("Window Monitor - Position-Based Window Management")
    print("=" * 70)
    
    if not WINDOW_RULES:
        print("WARNING: No window rules configured!")
        print("Edit config.py to add rules.\n")
        return
    
    monitor = WindowMonitor(WINDOW_RULES, CHECK_INTERVAL, NOT_FOUND_CALLBACK_INTERVAL)
    monitor.run()


if __name__ == "__main__":
    main()
