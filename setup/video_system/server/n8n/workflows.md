# N8N Workflows

This document describes all n8n automation workflows used in the CCP video system. The workflows orchestrate the full A/V production pipeline: ATEM switcher control, livestream management, camera control, video playback, logging, and congregation-facing features.

---

## Active Workflows

---

### Main
Workflow file: [f8eQySUHVPeEQpVT](n8n_workflows/f8eQySUHVPeEQpVT.json)

The central command router for the entire production system. It listens for HTTP key press events on the `/keyinput` webhook and dispatches each command to the appropriate sub-workflow or device. This is the single entry point used by all physical control surfaces and web remote controls.

Commands handled include PTZ camera movements (8 directions, zoom in/out), camera preset recalls (Pulpit, Stage, Projector, Sitting, Custom), ATEM program source switching (Camera, Projector, AV PC, Media Player), USK overlay toggling, fade-to-black toggling, and livestream lifecycle events (pre-stream, break, finish, navigated away). It also triggers shorts timestamp recording when an operator wants to mark a highlight clip.

---

### Event Manager
Workflow file: [mooEWAfPCkfAoJCv](n8n_workflows/mooEWAfPCkfAoJCv.json)

Manages the full lifecycle of a live service session. 

It can be called as a sub-workflow with a command argument, but it is also triggered on a schedule to handle ATEM initialization and auto-loading the default preset on startup.

The supported session commands are: 
 * `do_prestream` (switches the ATEM to show the looping pre-stream video and disables live audio),
 * `do_break` (stops recording, plays "continuing soon" video), 
 * `do_finish` (plays finish slide video, fades to black, stops recording, and shuts down the restreamer outputs) 
 * `start_session` (begins recording, enables live audio input, and starts all configured stream outputs).

---

### ATEM
Workflow file: [Dgk7CxGWHSHsNcoT](n8n_workflows/Dgk7CxGWHSHsNcoT.json)

The low-level ATEM switcher control interface. Since n8n has no native ATEM plugin, this sub-workflow acts as a translation layer — it accepts named command parameters and converts each into a formatted POST request 
to Bitfocus Companion's custom variable API. 
Companion then executes the corresponding real ATEM action via its own trigger system.

Supported commands cover a wide range of ATEM functionality: 
 * setting the program source,
 * toggling USK keyers, 
 * managing Fairlight audio (input mix enable/disable), 
 * controlling the Media Player
 * managing recording start/stop, 
 * setting aux outputs. 

Nearly every other workflow that needs to control the ATEM does so by calling this sub-workflow.

---

### Auto Starter
Workflow file: [fFXyk8UoUrM2yx6R](n8n_workflows/fFXyk8UoUrM2yx6R.json)

Provides fully automatic, schedule-driven service startup. It runs every minute and checks the current day and time against a `timed_start` schedule defined in the system configuration. 
If the current time matches a configured entry (E.g. sunday-08:45), it triggers the complete startup sequence without any manual intervention.

The automated startup sequence:
 * loads the appropriate preset, 
 * moves the PTZ camera to the pulpit position, 
 * stops any leftover recording from a previous session, 
 * plays the countdown video, 
 * switches the ATEM to show the countdown on program, 
 * and then — once the countdown finishes — switches to the live camera feed and calls the Event Manager's `start_session` command to begin recording and streaming.

---

### Read Config
Workflow file: [CgSbDSo1mHpiRCnr](n8n_workflows/CgSbDSo1mHpiRCnr.json)

A foundational utility sub-workflow called by virtually every other workflow in the system. 
It reads the global configuration JSON blob and the currently active preset name from the n8n data tables, then merges the two — overlaying the selected preset's settings on top of the global defaults.

The resulting merged config object is returned to the caller and provides all runtime settings: 
 * restreamer output names, 
 * recording filename prefix, 
 * welcome background image path, 
 * pre-stream video paths, 
 * camera presets, 
 * Companion and browser endpoint URLs, and timed start schedules.

Centralising config access in this way means settings only need to be updated in one place.

---

### Preset Manager
Workflow file: [YdhwWL3hSgPUVoxo](n8n_workflows/YdhwWL3hSgPUVoxo.json)

A preset is every configuration related to a live session.
For example our church has some custom backgrounds, has specific yt/facbook accounts, and also the pre stream, the automated countdown, the finish video files are configured in this preset.

There can be any number of preset, e.g. for another church using our system: they can have different designs, different streaming endpoints, etc.

This loads a named service preset and configures the production system accordingly. 
A preset is a named bundle of settings — for example "ccp" or "chinese" — that customises the system for a specific congregation or service type.

When called with a preset name:
 * it updates the active preset in the database, 
 * loads the preset's welcome background image into ATEM Media Player 1, 
 * sets the recording filename prefix (with a timestamp for uniqueness), 
 * routes the Media Player to the ATEM program output and the projector AUX channel to display the welcome slide, 
 * and moves the PTZ camera to the pulpit starting position.
 * This single call is sufficient to reconfigure the entire system from one service type to another.

---

### Stream Manager
Workflow file: [6NPqhmV3MOUnctVX](n8n_workflows/6NPqhmV3MOUnctVX.json)

Controls the live streaming outputs for the currently active preset. It accepts a single `set_streams_status` parameter (1 to enable, 0 to disable) and enables or disables all streaming destinations — typically YouTube and Facebook — that are defined in the current preset's configuration.

It works by reading the config via Read Config and then iterating over the preset's output names, calling the Restreamer sub-workflow for each one. 

This abstraction means the Event Manager only needs to call Stream Manager once to start or stop all streams, regardless of how many outputs are configured for the active preset.

---

### Restreamer
Workflow file: [0AUTg9h7jIJdrnCK](n8n_workflows/0AUTg9h7jIJdrnCK.json)

A low-level sub-workflow that communicates directly with the datarhei Restreamer API to manage individual streaming outputs. 
It accepts an output name and optional stream key values, then reads the current configuration before making a PUT request to the Restreamer REST API.

When enabling or disabling an output it toggles its enabled state. 
When stream keys are provided instead, it updates the YouTube or Facebook RTMP stream keys for the named output. 
This allows the system to reconfigure stream destinations at runtime without manual access to the Restreamer web UI.

---

### Log
Workflow file: [E0yl55s1YkCD2LNx](n8n_workflows/E0yl55s1YkCD2LNx.json)

The central logging and error-reporting system for the entire workflow suite. 
It operates in three modes: 
 * as a callable sub-workflow that inserts a timestamped log entry into the n8n log data table (automatically pruning entries older than 24 hours); 
 * as a global Error Trigger that catches unhandled failures in any workflow, logs the error, and sends an alert email via the Send Email sub-workflow; 
 * and as a webhook at `/getlogs` that returns the most recent 10 hours of log entries sorted newest-first for display in operator dashboards.

---

### Send Email
Workflow file: [xrGdCgP0Sg3dM3Ft7orlh](n8n_workflows/xrGdCgP0Sg3dM3Ft7orlh.json)

A simple transactional email sub-workflow. It accepts `to`, `subject`, and `body` parameters and delivers the message via the Resend API. 
It is used primarily by the Log workflow to send error alert emails to system administrators when a workflow fails unexpectedly.

---

### Video Player
Workflow file: [FK8D44cxEXsOJz7z](n8n_workflows/FK8D44cxEXsOJz7z.json)

Controls VLC media player via its HTTP API on the RPI. When called with a file path it stops any currently playing media and starts playback of the specified file. 
It accepts a `repeat` flag for looping content and a `stop` flag to halt playback without starting anything new.

The sub-workflow distinguishes between image files and video files: images always play in a loop (since they are static and used as holding slides), while videos respect the caller's repeat flag. 
This is used to play pre-stream loops, countdown videos, and break slides on the ATEM's video player input.

---

### Browser
Workflow file: [vGC4rpFc0kzVwrtT](n8n_workflows/vGC4rpFc0kzVwrtT.json)

A minimal sub-workflow that navigates a kiosk/headless browser to a given URL. 
It posts the target URL to the configured browser control endpoint. 
Other workflows use this to load specific HTML pages — such as the nursery call notification screen or the browser notification — so that the browser's output (fed into the ATEM as a source) displays the correct content at the right moment.

---

### Browser Notification
Workflow file: [oKYuBwn0nJ3SpMblzAqQ9](n8n_workflows/oKYuBwn0nJ3SpMblzAqQ9.json)

Displays a text notification on the browser-based ATEM source overlay. 
It can be triggered via a POST webhook at `/browser-notification` or called directly by another workflow with a message text. 
Before navigating the browser it checks a `browser_page_locked` flag to avoid overwriting a page that is currently in active use (such as the nursery call screen), waiting until the lock is released before proceeding.

Once the lock is clear it calls the Browser sub-workflow to load a notification HTML page with the provided text rendered on screen. This allows the system to push operator alerts or announcements directly onto the video output without manual intervention.

---

### Nursery Call
Workflow file: [JpetspgVx6Id7XV7LcU82](n8n_workflows/JpetspgVx6Id7XV7LcU82.json)

Handles the congregation nursery paging system. 
It exposes a webhook at `/nurserycall` where nursery staff can submit a call code (protected by a password). 
The call is stored in the database with a timestamp. A second trigger runs on a 5-second schedule and checks whether a new, unshown call has arrived within the last 60 seconds.

When a new call is detected:
 * the workflow loads the nursery notification HTML page in the kiosk browser, 
 * switches the PROGRAM aux to show the supersource (that has PROGRAM as background, and the cropped positioned browser in the bottom right corner) 
 * and marks the call as shown. 
 * After 60 seconds it automatically reverts PROGRAM aux to show the PROGRAM.

---

### Shorter
Workflow file: [t2Sa0MfLHA25zPqyi4tOG](n8n_workflows/t2Sa0MfLHA25zPqyi4tOG.json)

Manages the recording of timestamped highlight clips for short-form video content. 
When called by the Main workflow (triggered by an operator key press), it queries Companion for the current ATEM recording duration, filename, and index, then inserts a new entry into the `shorts` data table with a clip window of ±5 minutes around the current playback position.

It also exposes a webhook at `/get-shorts` that returns all recorded shorts timestamps for a given recording folder. 
This endpoint is used by post-production tooling — specifically the `video-processor` container that runs nightly — to automatically extract and prepare the marked highlight segments.

