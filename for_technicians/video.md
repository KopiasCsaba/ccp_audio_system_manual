<h1>DOING THE LIVE STREAM</h1>
<hr>

# STREAM lifecycle on sundays

* **10:01:** It will start to stream automatically with the "PRE-STREAM" scene
    * This helps people to tune in, check audio and video settings, etc.
* **10:30:** It will switch to the "PULPIT" scene, turn the camera there, etc.

* **During the service:** the camera will move based on the audio technician's handling of the microphone mutes.

* **11:50:** The end-of-stream scene will become active on the preview side only, this causes nothing yet.

* **AFTER THE BLESSING:**
  * **YOU** should press the "Transition" button to make the final scene active.
  * This will stop the recording and the live stream also.

<div style="page-break-after: always;"></div>

# Troubleshooting

## No audio input coming to OBS

If you see, that there is no audio coming to OBS:

Sometimes the audio input device in OBS is reset to something else, than LINE IN.

1. Click on the audio input's three dots (the one that is the highest)
1. Select Properties
1. Select LINE IN
1. Press OK

<img alt="" src="assets/video/screenshots/troubleshoot_obs_audio_input.png" height="200">

## No audio in the office TV

* Open OBS Settings
* Audio section
* Advanced
* The "monitoring device" should be "SONY TV (2- NVIDIA High Definition Audio)"

<img alt="" src="assets/video/obs_audio_monitor.png" height="200">

<div style="page-break-after: always;"></div>

## Restarting the stream on one of the platforms

### About our YouTube stream

* Our OBS is scripted, so when the OBS live stream starts, it (OBS) executes a command that automatically
  starts a new live event on YouTube.
* So if you stop streaming, then re-start, then it will automatically restart youtube also.
* But you might not want to stop streaming, as it will break other platforms that might be still going, e.g. facebook.

#### Restarting the YouTube stream

* In this case, you need to manually start again the youtube live stream:
    * Open the browser on the PC
    * Click on the "Youtube LIVE" bookmark
    * After this, proceed to [Re-starting just one platform's stream](#restarting-just-one-platforms-stream)
    * Restart youtube's stream as shown there
    * Come back to the youtube live page, and press the go LIVE button.

### About our Facebook stream

* Facebook can't be auto-started, but events can be created in advance, and they can be set as recurring.
* So for some of our events, facebook live is pre-scheduled for a half year or so.
* This means, that if we start to stream at the right (scheduled) time, facebook is going live automatically.
* But if the stream fails, that scheduled event will stop, and if you want to re-start it you have to initiate a
  facebook live event manually.

#### Restarting the Facebook stream

* Open the browser on the PC
* Click on the "FB: GO LIVE" bookmark
* Click on the "GO LIVE" button

Edit the post's details:

<img alt="" src="assets/video/screenshots/fblivedetailedit.png" height="300">

Type in the title and description:

* For title, we use the format "Title of Sermon - Main Passage - Full name of Pastor",
* But if you are in a hurry, go with "Church Service", someone will rename it later on.
* For description, you must write something as it will not let you stream otherwise. Usually we write "Good morning
  church!"

<img alt="" src="assets/video/screenshots/fb_live_post_Details.png" height="300">

* After this, proceed to [Re-starting just one platform's stream](#restarting-just-one-platforms-stream), and then come
  back to here.
* Restart facebook's stream
* Now press Go Live on facebook:

<img alt="" src="assets/video/screenshots/fb_start_stream.png" height="300">

### Restarting just one platform's stream

* Open up the browser
* Press the "RESTREAMER" bookmark on the bookmarks toolbar
* Log in (the user/pass is saved into the browser)
* Turn off one off the problematic source, and turn it back on, that will reconnect the stream.

<img alt="" src="assets/video/screenshots/restreamer_sources.png">
