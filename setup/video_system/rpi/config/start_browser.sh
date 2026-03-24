#!/bin/bash
# Brave browser starter for kiosk mode
# Note: Managed by systemd (brave.service) - dependencies and restarts handled by systemd

# DISPLAY is set by systemd via EnvironmentFile

# HTML content for the page
HTML='<html>
<head>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    body {
      background: #00ff00;
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      font-family: sans-serif;
    }
    h1 {
      color: #000;
      font-size: 8rem;
      font-weight: 300;
    }
  </style>
</head>
<body>
  <h1>BROWSER IS READY</h1>
</body>
</html>'

# URL-encode the HTML using python3
ENCODED_HTML=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$HTML'''))")

# Create user data directory and preferences file to suppress all notifications
# IMPORTANT: Use persistent location (not /tmp) so preferences survive reboots
USER_DATA_DIR="$HOME/.config/brave-kiosk"
mkdir -p "$USER_DATA_DIR/Default"

# CRITICAL: Create Local State file with P3A acknowledgment BEFORE Brave starts
# This is the ONLY way to suppress the P3A notification permanently
cat > "$USER_DATA_DIR/Local State" << 'LOCALEOF'
{
  "brave": {
    "p3a": {
      "enabled": false,
      "notice_acknowledged": true
    },
    "brave_ads": {
      "enabled": false
    }
  },
  "browser": {
    "check_default_browser": false
  }
}
LOCALEOF

# Create comprehensive Preferences file with all known suppression settings
cat > "$USER_DATA_DIR/Default/Preferences" << 'PREFEOF'
{
  "brave": {
    "stats_reporting": {
      "enabled": false
    },
    "p3a": {
      "enabled": false,
      "notice_acknowledged": true
    },
    "p3a_notice_acknowledged": true,
    "brave_ads": {
      "enabled": false
    },
    "new_tab_page": {
      "super_referral_themes_option": 1
    }
  },
  "profile": {
    "default_content_setting_values": {
      "notifications": 2
    },
    "exited_cleanly": true,
    "exit_type": "Normal"
  },
  "browser": {
    "show_update_promotion_info_bar": false,
    "has_seen_welcome_page": true,
    "check_default_browser": false
  },
  "distribution": {
    "skip_first_run_ui": true,
    "show_welcome_page": false,
    "import_bookmarks": false,
    "import_history": false,
    "import_search_engine": false,
    "make_chrome_default_for_user": false,
    "suppress_first_run_bubble": true
  }
}
PREFEOF

# systemd will restart if browser crashes
exec brave-browser --app="data:text/html,$ENCODED_HTML" \
 --autoplay-policy=no-user-gesture-required `# Allow videos to autoplay without user interaction` \
 --bwi=never `# Brave Wallet Install: never show wallet installation prompts` \
 --disable-background-mode `# Prevent browser from running in background` \
 --disable-background-networking `# Disable all background network requests` \
 --no-dbus `# Disable D-Bus to prevent connection errors in kiosk mode` \
 --disable-brave-google-sign-in `# Disable Brave Google sign-in feature` \
 --disable-brave-rewards `# Disable Brave Rewards system` \
 --disable-brave-tor `# Disable Brave Tor integration` \
 --disable-brave-update `# Prevent Brave from checking for updates` \
 --disable-brave-wayback-machine `# Disable Brave Wayback Machine integration` \
 --disable-breakpad `# Disable crash reporting system (Breakpad)` \
 --disable-client-side-phishing-detection `# Disable phishing detection to reduce network calls` \
 --disable-component-extensions-with-background-pages `# Prevent background extensions from loading` \
 --disable-component-update `# Disable automatic component updates` \
 --disable-crash-reporter `# Disable crash reporter` \
 --disable-datasaver-prompt `# Disable data saver prompts` \
 --disable-default-apps `# Don't load default apps` \
 --disable-dinosaur-easter-egg `# Disable offline dinosaur game` \
 --disable-domain-reliability `# Disable domain reliability monitoring` \
 --disable-extensions `# Disable all browser extensions` \
 --disable-features-list `# Suppress display of disabled features list` \
 --disable-features=AutofillServerCommunication,BraveNews,BraveRewards,BraveVPN,BraveWallet,CalculateNativeWinOcclusion,CastMediaRouteProvider,DialMediaRouteProvider,EnableTLS13EarlyData,MediaRouter,OptimizationHints,Prerender2,PrivacyGuide,PrivacySandboxSettings3,PrivacySandboxSettings4,ProductivityFeaturesMetricsLogging,TouchpadOverscrollHistoryNavigation,TranslateUI `# Disable specific Chromium/Brave features` \
 --disable-hang-monitor `# Disable hang monitor to prevent "page unresponsive" dialogs` \
 --disable-infobars `# Disable all information bars` \
 --disable-logging `# Disable logging to reduce I/O` \
 --disable-notifications `# Disable browser notifications` \
 --disable-permissions-api `# Disable permissions API to prevent permission prompts` \
 --disable-pinch `# Disable pinch-to-zoom gesture` \
 --disable-plugins-discovery `# Don't discover/load plugins` \
 --disable-popup-blocking `# Allow popups (in case notifications are treated as popups)` \
 --disable-presentation-api `# Disable presentation API` \
 --disable-print-preview `# Disable print preview` \
 --disable-prompt-on-repost `# Don't prompt when resubmitting forms` \
 --disable-renderer-accessibility `# Disable accessibility tree to improve performance` \
 --disable-save-password-bubble `# Don't show password save prompts` \
 --disable-search-engine-choice-screen `# Skip search engine selection screen` \
 --disable-session-crashed-bubble `# Don't show "browser didn't shut down correctly" message` \
 --disable-software-rasterizer `# Force hardware rendering, disable software fallback` \
 --disable-speech-api `# Disable speech recognition API` \
 --disable-sync `# Disable Brave Sync feature` \
 --disable-translate `# Disable page translation feature` \
 --disable-webrtc `# Disable WebRTC to prevent network leaks` \
 --disk-cache-size=52428800 `# Set disk cache to 50MB` \
 --display="$DISPLAY" `# X11 display to use` \
 --enable-accelerated-video-decode `# Enable hardware video decoding` \
 --enable-features=VaapiVideoDecoder `# Enable VA-API hardware video decoding` \
 --enable-gpu-rasterization `# Use GPU for rasterization (rendering)` \
 --enable-hardware-overlays `# Use hardware overlays for compositing` \
 --enable-zero-copy `# Enable zero-copy texture upload to GPU` \
 --ignore-gpu-blocklist `# Ignore GPU blocklist, force GPU acceleration` \
 --incognito `# Run in incognito/private mode (no history, cookies, etc.)` \
 --media-cache-size=52428800 `# Set media cache to 50MB` \
 --metrics-recording-only `# Only record metrics locally, don't send` \
 --no-default-browser-check `# Don't check if Brave is the default browser` \
 --no-first-run `# Skip first-run experience` \
 --no-pings `# Disable hyperlink auditing pings` \
 --no-sandbox `# Disable Chrome sandbox (required for some embedded systems)` \
 --noerrdialogs `# Don't show error dialogs` \
 --overscroll-history-navigation=0 `# Disable swipe-to-navigate gestures` \
 --password-store=basic `# Use basic password store (not system keyring)` \
 --pull-to-refresh=0 `# Disable pull-to-refresh gesture` \
 --remote-debugging-port=9222 `# Enable remote debugging on port 9222` \
 --safebrowsing-disable-auto-update `# Disable Safe Browsing auto-updates` \
 --start-fullscreen `# Start in fullscreen mode` \
 --test-type `# Suppress some automation warnings` \
 --use-gl=egl `# Use EGL (required for Raspberry Pi 5 GPU)` \
 --use-angle=default `# Use ANGLE for OpenGL ES translation` \
 --user-data-dir="$USER_DATA_DIR" `# Directory for browser profile data` \
 --window-position=1920,0 `# Position window at coordinates (1920, 0)` \
 --window-size=1920,1080 `# Set window size to 1920x1080`
