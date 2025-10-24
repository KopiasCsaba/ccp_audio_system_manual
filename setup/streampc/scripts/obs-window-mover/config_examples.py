# Window Monitor Configuration Examples
# Copy these examples into the WINDOW_RULES dictionary in window_monitor.py

# ============================================================================
# MATCHING METHODS
# ============================================================================
# You can identify monitors using 5 different methods:
#   1. Manufacturer name: "Sony", "Dell", "LG" (recommended when available)
#   2. Position X only: "x:3200" or "x=3200" (great for horizontal layouts)
#   3. Position X,Y: "3200,0" or "pos:3200,0" (most precise)
#   4. Device name: "DISPLAY1", "DISPLAY2"
#   5. Friendly name: "Dell 1708FP", "Generic PnP Monitor"


# ============================================================================
# EXAMPLE 1: Using Manufacturer Names (RECOMMENDED)
# ============================================================================
WINDOW_RULES = {
    "Full-screen Projector": {"monitor": "Sony", "fullscreen": True},
    "OBS": {"monitor": "Sony", "fullscreen": True},
    "Notepad": {"monitor": "Dell"},
}


# ============================================================================
# EXAMPLE 2: Using X Position Only (Simple & Reliable)
# ============================================================================
WINDOW_RULES = {
    "Full-screen Projector": {"monitor": "x:3200", "fullscreen": True},  # Rightmost monitor
    "Notepad": {"monitor": "x:0"},                                       # Leftmost monitor
    "Chrome": "x:1280",                                                  # Middle monitor (short syntax)
}


# ============================================================================
# EXAMPLE 3: Using Full X,Y Position
# ============================================================================
WINDOW_RULES = {
    "Full-screen Projector": {"monitor": "3200,0", "fullscreen": True},
    "Notepad": {"monitor": "0,0"},
    "Chrome": "1280,-46",
}


# ============================================================================
# EXAMPLE 4: Using Device Names
# ============================================================================
WINDOW_RULES = {
    "Notepad": {"monitor": "DISPLAY2"},
    "Chrome": {"monitor": "DISPLAY1"},
    "Spotify": {"monitor": "DISPLAY3"},
}


# ============================================================================
# EXAMPLE 5: Mixed Approach (Use best method for each monitor)
# ============================================================================
WINDOW_RULES = {
    "OBS": {"monitor": "Sony", "fullscreen": True},  # Use manufacturer when detected
    "Notepad": {"monitor": "Dell"},                  # Use manufacturer when detected
    "Chrome": {"monitor": "x:1280"},                 # Use X position for generic monitors
}


# ============================================================================
# EXAMPLE 6: Developer Workstation
# ============================================================================
WINDOW_RULES = {
    "Visual Studio Code": {"monitor": "Dell"},      # Code editor on Dell
    "Terminal": {"monitor": "Dell"},                # Terminal on Dell
    "Chrome": {"monitor": "Sony"},                  # Browser on Sony
    "Postman": {"monitor": "Sony"},                 # API testing on Sony
    "Slack": {"monitor": "x:1280"},                 # Communication (X position)
    "Spotify": {"monitor": "x:1280"},               # Music (X position)
}


# ============================================================================
# EXAMPLE 6: Content Creator Setup
# ============================================================================
WINDOW_RULES = {
    "Adobe Premiere": "Sony",                # Main editing on Sony (4K)
    "Photoshop": "Sony",                     # Photo editing on Sony
    "Chrome": "Dell",                        # Reference on Dell
    "Discord": "Dell",                       # Communication on Dell
    "OBS": "3200,0",                         # Streaming on third monitor
    "Spotify": "3200,0",                     # Music on third monitor
}


# ============================================================================
# EXAMPLE 7: Gaming/Streaming Setup
# ============================================================================
WINDOW_RULES = {
    "Discord": "pos:1280,-46",               # Voice chat on second screen
    "Spotify": "pos:1280,-46",               # Music on second screen
    "OBS Studio": "3200,0",                  # Streaming controls on third
    "Chrome": "1280,-46",                    # Guides/wiki on second
}


# ============================================================================
# EXAMPLE 8: Trading/Finance Workstation
# ============================================================================
WINDOW_RULES = {
    "TradingView": "0,0",                    # Charts on left (position-based)
    "Bloomberg": "1280,-46",                 # Main terminal in center
    "Excel": "3200,0",                       # Spreadsheets on right
    "Chrome": "1280,-46",                    # News/research in center
    "Outlook": "3200,0",                     # Email on right
}


# ============================================================================
# EXAMPLE 9: Multiple Apps to Same Monitor (by manufacturer)
# ============================================================================
WINDOW_RULES = {
    # All communication apps to Sony monitor
    "Slack": "Sony",
    "Discord": "Sony",
    "Teams": "Sony",
    "Zoom": "Sony",
    
    # All development tools to Dell monitor
    "Visual Studio": "Dell",
    "PyCharm": "Dell",
    "Terminal": "Dell",
    
    # Browser on the center monitor (by position)
    "Chrome": "1280,-46",
}


# ============================================================================
# EXAMPLE 10: Using Exact Positions for Precision
# ============================================================================
WINDOW_RULES = {
    "OBS": "pos:3200,0",                     # Exact position format
    "Full-screen Projector": "pos:3200,0",   # Same monitor
    "Notepad": "pos:0,0",                    # Different monitor
    "Chrome": "pos:1280,-46",                # Third monitor
}


# ============================================================================
# TIPS FOR CONFIGURATION
# ============================================================================

# 1. Monitor Identification Methods (in order of preference)
#    a) Manufacturer: "Sony", "Dell", "LG", "Samsung"
#       - Most reliable and readable
#       - Detected from EDID data
#    b) Position: "3200,0" or "pos:1280,-46"
#       - Best fallback when manufacturer not detected
#       - Use X,Y coordinates from script output
#    c) Device Name: "DISPLAY1", "DISPLAY2"
#       - May change if monitors reconnected
#    d) Friendly Name: "Dell 1708FP", "Generic PnP Monitor"
#       - Often not unique for generic monitors

# 2. Window Titles
#    - Use partial matches: "Chrome" matches "Google Chrome - Some Page"
#    - Match the application name for best results
#    - Case doesn't matter: "chrome" matches "Chrome"

# 3. Finding Your Monitor Information
#    - Just run the script! It will list all monitors with:
#      * Manufacturer (if detected)
#      * Device name
#      * Friendly name
#      * Position (X, Y)
#      * Resolution

# 4. Position Format
#    - "3200,0" or "pos:3200,0" both work
#    - Must match exactly (no spaces)
#    - Get coordinates from script output

# 5. Testing Your Rules
#    - Start with just one or two rules
#    - Open the application and watch the console output
#    - Script will show which monitor it matched
#    - Adjust the window title or monitor identifier if needed

# 6. Supported Manufacturers
#    Dell, Sony, Samsung, LG, ASUS, Acer, BenQ, HP, Lenovo, AOC,
#    Philips, ViewSonic, Iiyama, NEC, Eizo
#    (If not in list, you'll see a 3-letter code like "SNY")
