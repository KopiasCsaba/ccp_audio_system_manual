# RPI5 Video & browser setup

Below is the full transcript of setting up an RPI5 to:
 - Show VLC in one HDMI output
 - Show a fullscreen brave on the another HDMI output
 - Run our keys.py (basically a keylogger) that forwards key presses to N8N, allowing the remote controlling of our gear based on hotkeys with the macro keyboard.
 - Run start_browser_controller.py that listens for commands to remote control the brave instance to load webpages
 - Contain our media files
 - Run mediamtx that allows us to remotely see the multiview of the ATEM.
 - Have a read-only filesystem


# Architecture Overview

This setup creates a minimal kiosk system with:
- **Single X11 server with unified desktop** (no Wayland, no desktop environment)
  - X server :0 with one Screen spanning both displays (RandR extended desktop)
  - HDMI-1 at position 0+0 → VLC fullscreen (DISPLAY=:0 with window position)
  - HDMI-2 at position 1920+0 → Brave fullscreen (DISPLAY=:0 with window position)
  - Total desktop resolution: 3840x1080 (dual 1920x1080)
- **Hardware acceleration** via Mesa/Glamor and libva/VAAPI
- **Openbox window manager** - lightweight, event-driven window management
  - Enforces window geometry to prevent apps from spanning multiple monitors
  - Replaces xdotool polling hack with proper X11 window management
  - ~5-10MB RAM footprint, industry standard for kiosks
- **No cursor** - X server started with -nocursor flag
- **Minimal memory footprint** - only one X server, Openbox, VLC, and Brave
- **Auto-start on boot** via systemd services with proper dependency management
  - xorg.service → openbox.service → {vlc.service, brave.service} → browser-controller.service
  - keys.service runs independently after xorg.service
- **Automatic restart on failure** - systemd handles process supervision and restarts
- **Centralized logging** - all logs via systemd journal (volatile storage for readonly filesystem)
- **Solves DRM master conflict** - single X server owns DRM, apps use X11 protocol

## Systemd Service Dependency Hierarchy

```
xorg.service (X11 server)
  ├─→ openbox.service (window manager)
  │     ├─→ vlc.service (media player)
  │     └─→ brave.service (browser)
  │           └─→ browser-controller.service (HTTP API for browser control)
  └─→ keys.service (keyboard input monitor)
  └─→ mediamtx.service (ATEM acts as a webcam, this one streams it via a web interface)
```

# SD card preparation with rpi-imager
- OS: Raspberry pi os lite, debian trixie based
- ssh password, no wifi, ssh enable with password


# Setup
These needs to be manually executed one by one for good measure.

```bash
# Sync all config stuff over to the pi.
rsync -rvP ./config avpi:~
```

Having prepared the SD-card, executing these commands on the PI would produce the needed PI setup. It is quite reproducible this way.
Maybe with time some things will need tuning, but this is how I set it up originally.

```bash
#
# On the pi...
#
sudo mv ~/config /config
# Fix rights on /config
sudo chmod +x /config/*.py /config/*.sh
sudo chmod -R 0775 /config
sudo chmod -R 0777 /config/media
sudo chown -R $(id -u):$(id -g) /config

#
# Fix HDMI outputs
#
# This is needed to properly boot and avoid conflicts with blackmagic sdi converters.
# This forces fixed settings for the output.
sudo sh -c "echo 'video=HDMI-A-1:1920x1080@60e video=HDMI-A-2:1920x1080@60e drm.edid_firmware=HDMI-A-1:edid/bmsdi.bin,HDMI-A-2:edid/bmsdi.bin' >> /boot/firmware/cmdline.txt"


#
# Install apps
#
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get full-upgrade -y
sudo apt-get install -y python3 alsa-utils fonts-noto-color-emoji alsa-ucm-conf libavcodec-extra v4l-utils ffmpeg python3-aiohttp python3-evdev vlc curl apt-transport-https imagemagick overlayroot

#
# Install brave browser
#
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"  | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update
sudo apt install -y brave-browser

#
# Install Xorg and hardware acceleration
#
sudo apt-get install -y xserver-xorg xserver-xorg-input-libinput xinit x11-xserver-utils  openbox

# Install Libva related stuff
sudo apt-get install -y mesa-utils mesa-va-drivers libva2 libva-drm2 vainfo

#
# Copy all config files to their places
#
# cfgtopcopy has a structure exactly to be copied over to a live system
sudo rsync -rv --keep-dirlinks /config/cfgtopcopy/ /

#
# Setup user rights
#
sudo usermod -a -G video,render,input $USER


# Add environment variables to user profile
TARGET_USER="${SUDO_USER:-ccpadmin}"
cat >> /home/$TARGET_USER/.bashrc << 'EOF'
# Load X11 environment from central config
if [ -f /config/xorg.env ]; then
    set -a  # Export all variables
    source /config/xorg.env
    set +a
fi
EOF


# Configure systemd for graphical kiosk mode
sudo systemctl set-default graphical.target

# Disable tty1 and tty7 to avoid it flickering, using ram, etc.
sudo systemctl disable --now getty@tty1.service getty@tty7.service
sudo systemctl mask getty@tty1.service getty@tty7.service

# Enable and start X server
sudo systemctl daemon-reload
sudo systemctl enable --now xorg.service

# Enable and start all kiosk services
sudo systemctl daemon-reload
sudo systemctl restart systemd-journald
sudo systemctl enable --now openbox.service vlc.service brave.service browser-controller.service keys.service vlc-healthcheck.timer

# Enable webcam streaming with mediamtx
sudo systemctl daemon-reload
sudo systemctl enable mediamtx.service
sudo systemctl start mediamtx.service

# Configure SSH: enable password & key authentication
sudo sed -i 's/^\s*#\?\s*PasswordAuthentication\s\+.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?PubkeyAuthentication .*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd

#
# Performance optimizations
#

# Disable automatic upgrades
sudo apt-get remove unattended-upgrades
sudo systemctl disable apt-daily.timer
sudo systemctl disable apt-daily-upgrade.timer
sudo systemctl stop apt-daily.timer
sudo systemctl stop apt-daily-upgrade.timer

# Speed up boot
sudo apt purge -y cloud-init

sudo bash -c 'f=/boot/firmware/cmdline.txt; [ -e "$f" ] || f=/boot/cmdline.txt; sed -i "s/$/  fastboot/" "$f"'
sudo systemctl disable --now bluetooth avahi-daemon hciuart triggerhappy # Disables bluetooth stuff
sudo systemctl disable --now cloud-init-local.service, cloud-init-network.service, cloud-init-main.service, cloud-final.service, cloud-config.service # cloud provisioning stuff
sudo systemctl mask NetworkManager-wait-online.service # Prevents waiting on network at boot

# Disable swap-related services (reduces SD card wear)
sudo systemctl disable --now dphys-swapfile.service
sudo systemctl mask dphys-swapfile.service
sudo swapoff -a

# Disable filesystem resize service (no longer needed after first boot)
sudo systemctl disable --now rpi-eeprom-update.service
sudo systemctl disable --now resize2fs_once.service
sudo systemctl mask resize2fs_once.service

sudo apt-get -y autoremove
sudo apt-get clean



sudo reboot

#
# Enable read only filesystem
#
sudo /config/togglerw.sh 
```


## Dev commands
### Reload configs
# On development machine, sync config to Pi
```bash
sudo rsync -rv --keep-dirlinks /config/cfgtopcopy/ /
sudo systemctl daemon-reload
sudo systemctl restart openbox.service vlc.service brave.service browser-controller.service keys.service mediamtx.service vlc-healthcheck.timer
```

## Troubleshooting and Management

Useful systemd commands for managing the kiosk system:

```bash
# Check status of all kiosk services
sudo systemctl status openbox vlc brave browser-controller keys mediamtx

# View recent logs from a specific service
sudo journalctl -u vlc.service -n 100

# Follow logs in real-time (like tail -f)
sudo journalctl -u brave.service -f

# View logs from all services since last boot
sudo journalctl -b

# View logs with priority filtering (err, warning, info, debug)
sudo journalctl -p err

# Restart a specific service
sudo systemctl restart vlc.service

# Stop a service (will auto-restart due to Restart=always)
sudo systemctl stop brave.service

# Temporarily disable auto-restart (until next boot)
sudo systemctl mask vlc.service
sudo systemctl unmask vlc.service  # Re-enable

# Check if a service failed
sudo systemctl is-failed vlc.service

# See service startup order and timing
systemd-analyze blame
systemd-analyze critical-chain xorg.service

# Clear old journal logs (if RAM usage is high)
sudo journalctl --vacuum-time=1h  # Keep only last 1 hour
sudo journalctl --vacuum-size=50M # Keep only 50MB
```









