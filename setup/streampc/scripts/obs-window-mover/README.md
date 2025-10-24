# Window Monitor - Device Name Based Window Management

A Python script that constantly monitors for windows with specific titles and automatically moves them to designated monitors **by device name** on Windows 11.

## Features

- 🔍 **Continuous Monitoring**: Constantly checks for windows matching your specified titles
- 🖥️ **Multiple Matching Methods**: Target monitors by device name, friendly name, or position (X, Y, or X-only)
- 🎯 **Multiple Rules**: Configure different windows to go to different monitors
- 📺 **Fullscreen Mode**: Optionally maximize windows on target monitors
- 🔒 **Move Once Option**: Choose per-window whether to move once or keep on screen continuously
- 🤖 **Auto-Open Windows**: Define callbacks to auto-open windows that don't exist (e.g., OBS projector via WebSocket)
- 📝 **Partial Matching**: Matches windows and device names containing your search terms (case-insensitive)
- ⚡ **Lightweight**: Low resource usage with configurable check intervals
- 📊 **Auto-Discovery**: Lists all connected monitors with their details on startup
- 🚀 **Auto-Start**: Includes Windows Task Scheduler XML for automatic startup
- 🔄 **Smart Tracking**: Automatically detects when windows close and starts tracking them again

## Requirements

- Windows 11 (or Windows 10)
- Python 3.7 or higher
- Multiple monitors (as many as you want to manage)

## Installation

1. **Install Python** (if not already installed):
   - Download from [python.org](https://www.python.org/downloads/)
   - Make sure to check "Add Python to PATH" during installation

2. **Install dependencies**:
   
   **Option A - Use requirements file:**
   ```bash
   pip install -r requirements.txt
   ```

   **Option B - Install directly (recommended):**
   ```bash
   pip install pywin32
   ```
   
   **If you get version errors, try:**
   ```bash
   pip install --upgrade pywin32
   ```

   **Or install the latest available version:**
   ```bash
   pip install pywin32>=305
   ```

## Usage

### Quick Start

1. **Run the script first** to see your monitor details:
   ```bash
   python window_monitor.py
   ```
   
   The script will display all your monitors:
   ```
   Monitor 1:
     Device Name: \\.\DISPLAY2
     Name: Dell 1708FP(Digital)
     Resolution: 1280x1024
     Position: (0, 0)
   
   Monitor 2:
     Device Name: \\.\DISPLAY1
     Name: Generic PnP Monitor
     Resolution: 1920x1080
     Position: (1280, -46)
   
   Monitor 3:
     Device Name: \\.\DISPLAY3
     Name: Generic PnP Monitor
     Resolution: 1360x768
     Position: (3200, 0)
   ```

2. **Edit config.py to set your window rules**:
   
   ```python
   WINDOW_RULES = {
       # Keep projector on screen (move back if moved away)
       "Full-screen Projector": {
           "monitor": "pos:3200",
           "fullscreen": True,
           "move_once": False,
           "on_not_found": open_obs_projector  # Auto-open if missing
       },
       
       # Move OBS once and leave it alone
       "OBS Studio": {
           "monitor": "pos:1280",
           "fullscreen": True,
           "move_once": True,
       },
   }
   ```

3. **Run the script**:
   ```bash
   python window_monitor.py
   ```

4. **Stop monitoring**: Press `Ctrl+C`

5. **Optional: Set up auto-start on boot** - See "Running in Background" section below

### Configuration Options

Edit `WINDOW_RULES` at the **top of window_monitor.py**:

```python
WINDOW_RULES = {
    # Full format with fullscreen:
    "Window Title": {"monitor": "Identifier", "fullscreen": True},
    
    # Full format without fullscreen:
    "Window Title": {"monitor": "Identifier"},
    
    # Short format (no fullscreen):
    "Window Title": "Identifier",
}

# Monitor Identifier can be:
# - Manufacturer: "Sony", "Dell", "LG"
# - Position X,Y: "3200,0" or "pos:3200,0"
# - Position X only: "x:3200" or "x=3200" (matches first monitor at that X position)
# - Device name: "DISPLAY1", "DISPLAY2"
# - Friendly name: "Dell 1708FP"

CHECK_INTERVAL = 1.0  # How often to check (in seconds)
```

### Configuration Examples

**Example 1: OBS Projector (Fullscreen)**
```python
WINDOW_RULES = {
    "Full-screen Projector": {"monitor": "Sony", "fullscreen": True},
    "OBS": {"monitor": "Sony", "fullscreen": True},
}
```

**Example 2: Using X Position Only**
```python
WINDOW_RULES = {
    "Full-screen Projector": {"monitor": "x:3200", "fullscreen": True},  # Any monitor at X=3200
    "Notepad": {"monitor": "x:0"},                                       # Any monitor at X=0
    "Chrome": "x:1280",                                                  # Short syntax
}
```

**Example 3: Mixed - Some Fullscreen, Some Not**
```python
WINDOW_RULES = {
    "OBS": {"monitor": "Sony", "fullscreen": True},      # Fullscreen
    "Notepad": {"monitor": "Dell"},                      # Just move and center
    "Chrome": "x:1280",                                  # Match by X position
}
```

**Example 4: Using Full X,Y Position**
```python
WINDOW_RULES = {
    "Full-screen Projector": {"monitor": "3200,0", "fullscreen": True},
    "Notepad": {"monitor": "0,0"},
    "Chrome": "1280,-46",  # Short syntax
}
```

## How It Works

1. On startup, the script discovers all connected monitors and displays their device names
2. The script enumerates all visible windows every second (configurable)
3. When it finds a window matching one of your configured titles
4. It looks up which monitor that window should go to
5. It automatically moves the window to the center of the target monitor
6. The window is brought to the foreground
7. Each window is only moved once (until it's closed and reopened)

## Auto-Opening Windows (OBS Projector)

You can configure the script to automatically open windows that don't exist using the `on_not_found` callback.

### OBS Projector Auto-Open

**1. Install OBS WebSocket library:**
```bash
pip install obsws-python
```

**2. Enable OBS WebSocket:**
- Open OBS → Tools → WebSocket Server Settings
- Check "Enable WebSocket server"
- Set a password
- Note the port (default: 4455)

**3. Configure in config.py:**

Edit the `open_obs_projector()` function:
```python
def open_obs_projector():
    """Open OBS fullscreen projector via WebSocket when window not found."""
    try:
        import obsws_python as obs
        
        client = obs.ReqClient(
            host='localhost',
            port=4455,
            password='YourPasswordHere'  # ← Change this
        )
        
        try:
            client.open_video_mix_projector(
                video_mix_type='OBS_WEBSOCKET_VIDEO_MIX_TYPE_PROGRAM',
                monitor_index=2,  # ← 0=primary, 1=second, 2=third
                projector_geometry=None
            )
            print("  → OBS Projector opened successfully!")
            return True
        finally:
            client.disconnect()
    except Exception as e:
        print(f"  → Failed to open OBS projector: {e}")
        return False
```

Then add it to your window rule:
```python
WINDOW_RULES = {
    "Full-screen Projector": {
        "monitor": "pos:3200",
        "fullscreen": True,
        "move_once": False,
        "on_not_found": open_obs_projector  # ← Auto-open
    },
}
```

**How it works:**
- Every 10 seconds, checks if "Full-screen Projector" window exists
- If missing, calls `open_obs_projector()`
- Opens projector via OBS WebSocket
- Window appears and gets positioned automatically
- Single error line if it fails (e.g., OBS not running)

## Running in Background / Auto-Start

### Option 1: Windows Scheduled Task (Recommended)

**Quick Setup:**

1. Open `WindowMonitor.xml` in a text editor
2. Update these paths:
   ```xml
   <Command>C:\Path\To\pythonw.exe</Command>
   <Arguments>"C:\Path\To\window_monitor.py"</Arguments>
   <WorkingDirectory>C:\Path\To</WorkingDirectory>
   ```
   Find your Python path with: `where pythonw` or `where python`

3. Open Command Prompt as Administrator and run:
   ```batch
   schtasks /Create /TN "WindowMonitor" /XML "C:\Path\To\WindowMonitor.xml" /F
   ```

**Or use Task Scheduler GUI:**
1. Press `Win + R`, type `taskschd.msc`, press Enter
2. Click "Import Task..." in the Actions pane
3. Select `WindowMonitor.xml`
4. Click OK

**Manage the task:**
```batch
# Run immediately (test)
schtasks /Run /TN "WindowMonitor"

# Stop running task
schtasks /End /TN "WindowMonitor"

# Delete task
schtasks /Delete /TN "WindowMonitor" /F
```

### Option 2: Startup Folder

1. Press `Win + R`, type `shell:startup`, press Enter
2. Create a shortcut with target:
   ```
   "C:\Path\To\pythonw.exe" "C:\Path\To\window_monitor.py"
   ```

**Note:** Doesn't run with elevated privileges.

## Troubleshooting

### "Monitor not found" error
- **Cause**: The device name in your rules doesn't match any connected monitor
- **Solution**: Run the script to see available monitor names, then update your rules with exact or partial matches

### Window doesn't move
- **Cause**: Window title doesn't match your rule
- **Solution**: Use partial matching (e.g., use "Chrome" to match "Google Chrome - Some Page Title")

### Wrong monitor
- **Cause**: Multiple monitors have similar names
- **Solution**: Use more specific device names or the full device path like `\\.\\DISPLAY1`

### Script stops after moving once
- **Cause**: This is by design - each window is only moved once to avoid constant repositioning
- **Solution**: Close and reopen the window if you need it moved again

### Permission errors
- **Cause**: Some windows require elevated permissions
- **Solution**: Run the script as Administrator (right-click → Run as administrator)

## Advanced Tips

### Monitor Matching Methods

The script supports **5 ways** to identify monitors:

1. **Manufacturer Name** (recommended when available)
   - Detected from EDID data
   - Examples: `"Sony"`, `"Dell"`, `"LG"`, `"Samsung"`
   - Most reliable and readable

2. **Position X only** (great for horizontal monitor arrangements)
   - Format: `"x:value"` or `"x=value"`
   - Examples: `"x:3200"`, `"x=1280"`, `"x:0"`
   - Matches the first monitor at that X coordinate
   - Perfect when Y position may vary

3. **Position X,Y** (most precise)
   - Format: `"x,y"` or `"pos:x,y"`
   - Examples: `"3200,0"`, `"pos:1280,-46"`
   - Best when you need exact position matching

4. **Device Name**
   - Format: `"DISPLAY1"`, `"DISPLAY2"`, etc.
   - May change if monitors are reconnected

5. **Friendly Name**
   - Examples: `"Dell 1708FP"`, `"Generic PnP Monitor"`
   - Often not unique for generic monitors

### Supported Manufacturers

The script automatically detects these manufacturers from EDID:
- Dell, Sony, Samsung, LG, ASUS, Acer, BenQ, HP, Lenovo, AOC, Philips, ViewSonic, Iiyama, NEC, Eizo

If your manufacturer isn't detected, you'll see the 3-letter manufacturer code (e.g., "SNY" for Sony).

### Finding Monitor Information

Three ways to identify your monitors:

1. **Run this script** - Shows all details including manufacturer
2. **Windows Settings** - Settings → System → Display
3. **Check position** - Note the X,Y coordinates shown in the script output

### Matching Examples

All matching is **partial and case-insensitive**:

**Manufacturer matching:**
```python
"Sony"      # Matches manufacturer "Sony"
"sony"      # Also matches (case-insensitive)
"Dell"      # Matches manufacturer "Dell"
```

**X position only matching:**
```python
"x:3200"         # Matches first monitor at X position 3200
"x=3200"         # Alternative syntax
"x:0"            # Matches first monitor at X position 0
"x:1280"         # Matches first monitor at X position 1280
```

**Full X,Y position matching:**
```python
"3200,0"         # Matches monitor at position (3200, 0)
"pos:1280,-46"   # Also matches monitor at (1280, -46)
"0,0"            # Matches monitor at origin
```

**Device name matching:**
```python
"DISPLAY1"       # Matches \\.\DISPLAY1
"display3"       # Matches \\.\DISPLAY3 (case-insensitive)
"DISPLAY"        # Matches any display (partial match)
```

**Friendly name matching:**
```python
"Dell 1708FP"    # Matches "Dell 1708FP(Digital)"
"1708FP"         # Also matches (partial)
"dell"           # Also matches (case-insensitive)
```

### Multiple Windows, One Monitor

You can send multiple window types to the same monitor:

```python
WINDOW_RULES = {
    "Slack": "DELL U2415",
    "Discord": "DELL U2415",
    "Teams": "DELL U2415",
}
```

### Window Title Matching Tips

- Use short, unique parts of titles: `"Chrome"` instead of `"Google Chrome"`
- Match application names: `"Spotify"`, `"Discord"`, `"Notepad"`
- Match document names: `"report.docx"`, `"presentation.pptx"`
- Partial matches work: `"Visual Studio"` matches `"Visual Studio Code"`

## License

MIT License - Feel free to modify and use as needed.

## Notes

- The script reads EDID data from the Windows registry to detect real manufacturer names
- If manufacturer can't be detected, use position-based matching (X only or X,Y) as a reliable fallback
- X-only matching (`x:3200`) is useful when monitors are at the same horizontal position but different vertical positions
- The script uses partial, case-insensitive matching for all identifiers
- Only visible windows are monitored
- Windows are centered on the target monitor
- The script prevents repeatedly moving the same window
- Each rule can target a different monitor using any matching method
- Multiple window types can target the same monitor
- Monitor information is discovered automatically on startup

## Finding Your Monitor Information

When you run the script, it will show comprehensive output like this:

```
Available Monitors
======================================================================

Monitor 1:
  Device Name: \\.\DISPLAY2
  Friendly Name: Dell 1708FP(Digital)
  Manufacturer: Dell
  Resolution: 1280x1024
  Position: (0, 0)                    ← X position is 0

Monitor 2:
  Device Name: \\.\DISPLAY1
  Friendly Name: Generic PnP Monitor
  Resolution: 1920x1080
  Position: (1280, -46)               ← X position is 1280

Monitor 3:
  Device Name: \\.\DISPLAY3
  Friendly Name: Generic PnP Monitor
  Manufacturer: Sony
  Resolution: 1360x768
  Position: (3200, 0)                 ← X position is 3200

======================================================================
You can match monitors using:
  1. Manufacturer name (e.g., 'Sony', 'Dell')
  2. Device Name (e.g., 'DISPLAY1')
  3. Friendly Name (e.g., 'Dell 1708FP')
  4. Position X,Y (e.g., '3200,0' or 'pos:3200,0')
  5. Position X only (e.g., 'x:3200' or 'x=3200')
```

Use whichever method works best for your monitors!
