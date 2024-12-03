<h1>CONFIGURATION REFERENCE</h1>
----

<h2>Table of contents</h2>

This document is under construction.

<!-- TOC -->

* [<h1>CONFIGURATION REFERENCE</h1>](#h1configuration-referenceh1)
* [Main speakers' settings](#main-speakers-settings)
    * [Front speakers](#front-speakers)
    * [Fill speakers](#fill-speakers)
    * [Coffee shop speakers](#coffee-shop-speakers)
    * [Rhode link settings](#rhode-link-settings)
* [Hardware](#hardware)
    * [Projector](#projector)
    * [Coffeshop TV (LG)](#coffeshop-tv-lg)
    * [Pole TV (Century)](#pole-tv-century)
    * [PTZ Camera](#ptz-camera)
    * [Baby-room TV](#baby-room-tv)
* [Streaming PC](#streaming-pc)

<!-- TOC -->

<div style="page-break-after: always;"></div>

# Main speakers' settings

## Front speakers

<img alt="" src="../for_technicians/assets/reset/mains.png" align="right" style="float:right" height="300">

* Ch 2 Level at **9 o'clock**
* DSP D-contour **OFF**
* DSP HPF **OFF**
* Gray button **NOT** pressed in

<br clear="both" style="clear:both"/>

## Fill speakers

<img alt="" src="../for_technicians/assets/reset/fills.png" align="right" style="float:right"  height="300"/>

* Level at 9 o'clock
* High at 0
* Low at 0

<br clear="right" style="clear:right">


<div style="page-break-after: always;"></div>

## Coffee shop speakers

<img alt="" src="../for_technicians/assets/reset/coffeshop.png"  align="right" style="float:right" height="300"/>

* Volume at 9 o'clock
* DSP preset button NOT pressed in

<br clear="both" style="clear:both"/>

## Rhode link settings

* The receiver (the one on the wall) should be on 0db gain.
* The transmitter (the one with the mic) should be on 10db gain.

<img alt="" src="assets/config/rhodelink.png" height="200">

# Hardware

## Projector

* Used input: HDMI2 (not HDMI1/MHL)

* Display
    * Image settings
        * Display mode: sRGB
        * Wall color: Off
        * Brightness: 25
        * Contrast: -4
        * Sharpness: 10
        * Brightness mode: Power 100%
        * Gamma: Standard(2.2)
        * Color settings
            * BrilliantColor 1
            * Color Matching: (defaults, all 0)
            * RGB Gain/Bias: (defaults, all 0)
            * Color space: RGB(0~255)
    * Aspect ratio: 16:9
    * Edge Mask: 0
    * Zoom: 0
* Setup
    * Direct power on: off
    * Signal power on: off
    * Auto power off (min): 25
    * Power mode (Standby): Eco
    * HDMI Cec: OFF
    * Language: English
    * Auto Source: off
    * Input source: HDMI2
    * High altitude: off
    * Background color: LOGO
* Network
    * DHCP: ON

## Coffeshop TV (LG)

* Picture
    * Pisture mode settings
        * Picture mode: : Standard (User)
        * Backlight: 100
        * Contrest: 100
        * Brightness: 50
        * Sharpness: 10
        * Colour: 55
        * Tint: 0
        * Colour Temperature: C20
        * Advanced settings:
            * Gamma: High2
        * Black level: Auto
    * Aspect Ratio Settings: 16:9
    * Energy Saving: Off
* General
    * Standby Light: on
    * Settings help: on
    * Screen saver: off (**<-VERY IMPORTANT**)
    * No signal image: off (**<-VERY IMPORTANT**)

Important parts are important because otherwise the TV does not remember which input should it use the next time it is
turned on.

## Pole TV (Century)

* Picture
    * Picture mode: user
    * Brighness: 62
    * Contrast: 47
    * Saturation: 57
    * Sharpness: 0
    * Diplay mode: 16:9
    * Advanced picture
        * Color temp: standard
        * NR: OFF
        * Game mode OFF
        * PC MODE: PC
* Settings
    * HDMI CEC: OFF
    * Blue screen: off
    * Single listen: off

## PTZ Camera
### Webadmin
#### Video

![video_tab.png](streampc/exported_configurations/ptzoptics/video_tab.png)

#### Image

![image_tab.png](streampc/exported_configurations/ptzoptics/image_tab.png)

### OSD
| Setting                   | Pulpit & All other | Stage   |
|---------------------------|--------------------|---------|
| Exposure / Mode           | manual             | manual  |
| Exposure / Iris           | F1.8               | F1.8    |
| Exposure / Shutter        | 1/100              | 1/100   |
| Exposure / Gain           | 2                  | 3       |
| Exposure / DRC            | 0                  | 0       |
| Color / WB Mode OnePush   |                    |         |
| Color / RG Tuning         | 0                  | 0       |
| Color / BG Tuning         | 0                  | 0       |
| Color / Saturation        | 80%                | 80%     |
| Color / Hue               | 7                  | 7       |
| Color / AWB Sens          | High               | High    |
| Image /  Luminance        | 6                  | 6       |
| Image / Contrast          | 8                  | 8       |
| Image / Sharpness         | 3                  | 3       |
| Image / Flip-H            | Off                | Off     |
| Image / Flip-V            | Off                | Off     |
| Image / B&W-Mode          | Off                | Off     |
| Image / Gamma             | 0.5                | 0.5     |
| Image / Style             | Default            | Default |
| Image / LDC               | Off                | Off     |
| P/T/Z / Call preset speed | 24                 | 24      |
| SETUP Motion sync         | ON/230             | ON/230  |

* P/T/Z:
    * SpeedByZoom: On
    * AF Zone: Center
    * AF-Sense: High
    * L/R Set: STD
    * Display Info: ON
    * Image freeze: Off
    * Digital Zoom: Off
    * Pre zoom speed: 7
* Noise reduction:
    * NR2D-Level: 1
    * NR3D-Level: 1
* SETUP:
    * DVIMode: Hdmi
    * Lens: Type1
    * Auto scan: Off
    * Autofocus L: Off
    * OSD TimeOut: Off
    * Motion Sync:
        * Motion Sync: On
        * Max speed: 230
    * Focus Limit: off
    * Auto Inspect: off

## Baby-room TV

* Browser homepage & bookmark the restreamer page: https://tinyurl.com/tvstreamtest1
* Remove unneeded menu shortcuts, by "down arrow/remove".

# Streaming PC

* Disable "peeking" in performance settings
    * Open Visual Effects Performance Options (SystemPropertiesPerformance.exe)
    * Disable "Enable peek"
    * Reason: live screens might be disturbed during services
* Enable the automatic start of "Windows Time service" so time would be synced always.
    * Reason: the service live stream is timed, and have started at the wrong minute.
* Enable HDMI the hdmi capture's audio input to pass through the audio output
    * Run mmsys.cpl
    * "Recording" tab
    * Choose "Digital audio interface"
    * "Listen" tab
    * Enable    
* Make OBS auto start with some delay for docker to start before...
    * Windows+R
    * shell:startup
    * New shortcut
	* Start in: "C:\Program Files\obs-studio\bin\64bit"
	* Target: C:\Windows\System32\cmd.exe /c start "" /b /wait C:\Windows\System32\timeout.exe /T 20 /nobreak && start "" /b "C:\Program Files\obs-studio\bin\64bit\obs64.exe" --disable-shutdown-check
* Disable search indexind
* Disable WSL2 guiApplications: https://learn.microsoft.com/en-us/windows/wsl/wsl-config

# Console Read only preset

 * Left layer: Speaker
   * Headset fader: 0db
   * Pulpit fader: 0db
 * Right layer: GROUP DCA1-8
   * Speaker: -20db
   * Aux/PC: -20db
 * Mute groups: 
   * Effects: muted
   * Aux/PC: muted
 * Assign:
   * Headset: muted
   * Pulpuit: muted
   * Stage: ON
 * Instruments layer:
   * 1-5: INSTR UNUSED PRESET
 * Vocals layer: 1-4,6: VOC UNUSED PRESET

