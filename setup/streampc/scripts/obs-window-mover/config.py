"""
Configuration file for Window Monitor
Edit this file to customize window management rules
"""

# ============================================================================
# OBS PROJECTOR AUTO-OPEN FUNCTION
# ============================================================================

def open_obs_projector():
    """Open OBS fullscreen projector via WebSocket when window not found."""
    try:
        import obsws_python as obs
        
        client = obs.ReqClient(host='localhost', port=4455, password='WoodenTableWithPineapple')
        
        try:
            client.open_video_mix_projector(
                video_mix_type='OBS_WEBSOCKET_VIDEO_MIX_TYPE_PROGRAM',
                monitor_index=2,  # 0=primary, 1=second, 2=third monitor
                projector_geometry=None
            )
            print("  → OBS Projector opened successfully via WebSocket!")
            return True
        finally:
            client.disconnect()
            
    except Exception as e:
        print(f"  → Failed to open OBS projector: {e}")
        return False


# ============================================================================
# WINDOW RULES
# ============================================================================

# Map window titles to monitor positions and options
# Format: "Window Title": {"monitor": "pos:X", "fullscreen": True/False, "move_once": True/False, "on_not_found": function}
# 
# Monitor position format:
#   - "pos:3200" - X position only (matches first monitor at X=3200)
#
# Fullscreen option:
#   - True: Maximize window to fill the entire monitor (keeps window borders)
#   - False: Just move and center the window
#
# Move once option:
#   - True: Only move the window once when first detected, then ignore it until window is closed
#   - False: Continuously monitor and move window back if moved away
#
# On not found callback:
#   - A function to call when the window doesn't exist (e.g., open_obs_projector)
#   - Called every NOT_FOUND_CALLBACK_INTERVAL seconds when window is missing

WINDOW_RULES = {
    # Full-screen Projector - keep on screen (move back if moved away)
    # If window doesn't exist, try to open it via OBS WebSocket
    "Full-screen Projector": {
        "monitor": "pos:3200",
        "fullscreen": True,
        "move_once": False,
        "on_not_found": open_obs_projector
    },
    
    # OBS Studio - move once and leave alone
    "OBS Studio": {
        "monitor": "pos:1280",
        "fullscreen": True,
        "move_once": True,
    },
}

# How often to check for windows (in seconds)
CHECK_INTERVAL = 1.0

# How long to wait before calling on_not_found callback (in seconds)
# This prevents spam-calling the callback every second
NOT_FOUND_CALLBACK_INTERVAL = 1
