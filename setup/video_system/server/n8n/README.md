# N8N

N8n is our main automation, it is responsible for gluing all our components together.

Notable entry points:
 * The macro [keyboard](../../keyboard) via USB → RPI5 → keys.py sends → HTTP POST request to the [Mainwork flow](workflows.md#main)
 * Time: the [auto starter](workflows.md#auto-starter) workflow is responsible to start live streaming according to the current time based on the configuration. E.g. "sunday-08:45"
 * Power on: the [event manager](workflows.md#event-manager) is constantly looking for the ATEM and the PI, and when they first come online it initializes them.
 
More on workflows in [workflows.md](workflows.md)

# Automation system overview

Users interact with the system via the keyboard, which is captured and forwarded to the Main workflow in forms of HTTP requests that contain which button is pressed.


The Main workflow is a giant dispatcher that calls specific sub workflows based on the pressed key. Notably it handles the camera events separately.


# Configuration

The confiuration is stored as a JSON in the n8n config data table, and is looking like the one below.

## Structure
### timed_start
This is where the automated event starting can be configured. If the current day and time matches the key, then the session will be started
with configuration supplied. The timed_start events have a specified countdown video shown before them (see prestream_countdown_video in the presets)-

### presets
The system can be used by different groups, who might have different requirements for their live streaming endpoints, graphics, etc.
All these is encapsulated into "presets". 

### restreamer_map
This section maps user-readable names of restreamer endpoints to ids that can be used in the API calls to edit them. (enable/disable/set key)

### atem_map
Is a somewhat proprietary mapping that maps certain sources to an ID, we use that ID for calling on the ATEM, but we use the KEYS to know what are we talking about. (E.g. set_projector_to is PROJ)

## Example
```JSON
{
  "companion_host": "http://192.168.2.5:3001",
  "n8n_host": "http://192.168.2.5:3000",
  "vlc_endpoint": "http://192.168.2.200:8081",
  "vlc_pass": "vlcremote",
  "browser_endpoint": "http://192.168.2.200:9393",
  "camera_host": "http://192.168.2.104:80",
  "camera_pan_speed": 6,
  "camera_tilt_speed": 6,
  "camera_zoom_speed": 1,
  "restreamer_host": "http://192.168.2.5:3002",
  "restreamer_delay": 9,
  "$documentation": "restreamer_delay: The time it takes a real event to show up in the restreamer (atem-ffmpeg).",
  "video_load_delay": 3,
  "$documentation": "video_load_delay: The time it takes for the video to play",
  "timed_start": {
    "xxx-sunday-10:15": {
      "preset": "ccp",
      "set_projector_to": "PROJ",
      "do_streaming": true,
      "do_recording": true
    },
    "sunday-08:45": {
      "preset": "ccp",
      "set_projector_to": "PROJ",
      "do_streaming": false,
      "do_recording": false
    },
    "sunday-10:45": {
      "preset": "ccp",
      "set_projector_to": "PROJ",
      "do_streaming": true,
      "do_recording": true
    }
  },
  "presets": {
    "ccp": {
      "welcome_bg_still": 1,
      "clean_bg_still": 2,
      "recording_prefix": "CCP_",
      "prestream_infinite_video": "/config/media/presetfiles/ccp/prestream_infinite.mov",
      "prestream_countdown_video": "/config/media/presetfiles/ccp/prestream_countdown_15min.mov",
      "prestream_countdown_video_length_secs": 890,
      "break_video": "/config/media/presetfiles/ccp/break.mov",
      "finish_video": "/config/media/presetfiles/ccp/finish.mov",
      "finish_video_length_secs": "4",
      "restreamer_youtube": "ccp_youtube",
      "restreamer_facebook": "ccp_facebook"
    },
    "chinese": {
      "welcome_bg_still": 3,
      "clean_bg_still": 4,
      "recording_prefix": "CHINESE_",
      "prestream_infinite_video": "/config/media/presetfiles/chinese/loading_infinite.mkv",
      "prestream_countdown_video": "/config/media/presetfiles/chinese/loading_countdown.mkv",
      "prestream_countdown_video_length_secs": 1800,
      "break_video": "/config/media/presetfiles/chinese/break.mkv",
      "finish_video": "/config/media/presetfiles/chinese/finish.mkv",
      "finish_video_length_secs": "11",
      "restreamer_youtube": "chinese_youtube",
      "restreamer_facebook": "chinese_facebook"
    }
  },
  "restreamer_map": {
    "__DOC": "When restreamer admin page loads, in the browser debug toolbar, check the 'process?filter=metadata' request to get the id value (restreamer-ui:egress:...:...",
    "ccp_youtube": {
      "id": "restreamer-ui:egress:youtube:9672608b-2554-4751-bef2-481d8939d26e"
    },
    "ccp_facebook": {
      "name": "ccp_facebook",
      "id": "restreamer-ui:egress:facebook:6bee73df-a206-48fd-a22b-57867fba5d43"
    },
    "chinese_youtube": {
      "name": "chinese_youtube",
      "id": "restreamer-ui:egress:youtube:16b71150-b360-4187-8dca-09c96de8362f"
    },
    "chinese_facebook": {
      "chinese_facebook": "chinese_facebook",
      "id": "restreamer-ui:egress:facebook:49380525-1fa1-4207-909d-048f33f8a8a9"
    }
  },
  "atem_map": {
    "BLK": 0,
    "BLACK": 0,
    "CAM": 1,
    "PROJ": 2,
    "PULP": 3,
    "PVID": 4,
    "PBRO": 5,
    "AVPC": 6,
    "PLOO": 7,
    "I8": 8,
    "COLOR1": 2001,
    "COLOR2": 2002,
    "MPLAYER1": 3010,
    "MPLAYER2": 3020,
    "SSRC": 6000,
    "PROGRAM": 10010
  }
}
```

