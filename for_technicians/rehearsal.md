<h1>TASKS ON A REHEARSAL</h1>
<hr>


<!-- TOC -->
* [Reference on stage channel names](#reference-on-stage-channel-names)
* [Before the band arrives](#before-the-band-arrives)
  * [You should know the band setup](#you-should-know-the-band-setup)
  * [Reset the stage mixers](#reset-the-stage-mixers)
  * [Stage housekeeping](#stage-housekeeping)
  * [At the main console](#at-the-main-console)
    * [Mute pulpit and headset](#mute-pulpit-and-headset)
    * [Mute unused vocals](#mute-unused-vocals)
    * [Mute unused instruments](#mute-unused-instruments)
    * [Load channel presets](#load-channel-presets)
* [After the band arrives](#after-the-band-arrives)
  * [Gain staging](#gain-staging)
  * [Save the scene](#save-the-scene)
  * [During the rehearsal](#during-the-rehearsal)
    * [If a vocalist sounds off-key or unexpected](#if-a-vocalist-sounds-off-key-or-unexpected)
* [After the rehearsal](#after-the-rehearsal)
  * [Save the scene](#save-the-scene-1)
  * [Close up](#close-up)
<!-- TOC -->
<div style="page-break-after: always;"></div>

# Reference on stage channel names

<img src="../for_worship_team/assets/stage.jpg" height="400"/>

The logic is, that:

* Close to **Mic1** is the **Inst1** and **Inst2** cables.
* Close to **Mic3** is the **Inst3** cable.
* And the stage corner has **Inst4** and **Inst5** cables.

<div style="page-break-after: always;"></div>

# Before the band arrives

You should be there ~20minutes before them, to be able to set up
everything professionally and to avoid hurry-induced errors, fix random issues, etc.

* Follow the "[Setting up the system](settingup.md)" guide.

## You should know the band setup

* Who will be at which mic on the stage.
* Who will use which instrument.

Our worship related drive document should contain that information,
but alternatively you can consult about this with the worship leader also.

<div style="page-break-after: always;"></div>

## Reset the stage mixers

For all the stage mixers, including the one in the drum room, do the following, to reset them to their default working
state.

(Order is important here!)

1. Turn it on, if it's not on (switch is on the back side)
2. Reset the top-knobs as follows (and also on the image):
    * Equalizers section knobs (first four): **12 o'clock**
    * Limiter to **MAX**
    * Level to **3 o'clock**
3. Recall preset 16:
    * Press and hold **RECALL**
    * Press **16**
    * **Release** RECALL

<img alt="" src="assets/reset/stagemixer.png" height="300"> 

<div style="page-break-after: always;"></div>

## Stage housekeeping

* Fold back unused microphones.
* Turn down (turn level knob to zero) on monitors that will not be used.
* Clean up, move away obstacles, trash, etc.

## At the main console

### Mute pulpit and headset

* If **{Assign/PULPIT MUTE}** is gray, press it.
* If **{Assign/HEADSET MUTE}** is gray, press it.

### Mute unused vocals

* Press **{Layers/VOCAL}**: to select the vocals layer.
* **Mute** and **Pull down** unused channels between 1-6.
* Do not change channel 7 and 8.

### Mute unused instruments

* Press **{Layers/INSTR}** to select the instruments layer.
* **Mute** and **pull down** unused channels between 1-5.
* Don't change channels 6, 7, 8.

<div style="page-break-after: always;"></div>

### Load channel presets

Go through:

* **Vocal mics 1 to 6**, and
* **Instruments 1 to 5**

and for each used channel, load the appropriate preset, repeating the following steps:

<img src="assets/console/presetloading.png" height="200"/>

1. Press **{Layers/VOCAL}** OR **{Layers/INSTR}**: to select the right layer.
2. Press **{Channel X/SELECT}**: to select the channel where you want to load the preset.
3. Press **{Equalizer/VIEW}**:
    * No need to press again, if it is red already.

4. Press **{DisplaySide/UTILITY}**

5. Turn **{Knobs/SCOPE}**: and select the **RECALL SCOPE** option.

6. Press **{Knobs/SCOPE}**: to select **all scopes**.
    * It should look like the green area on the image.

7. Turn **{Knobs/LOAD PRESET}**: to select the appropriate preset.
    * "GTR ..." for guitars
    * "VOC ..." for vocalist (scroll down to find those)

8. Check, that you are on the right **LAYER** and the right **CHANNEL** is selected.

9. Press **{Knobs/LOAD PRESET}**: to load the preset.

10. Press **{Knobs/CONFIRM}**.

11. Repeat this section for the next vocal or instrument channel that is in use, or continue if you are finished.

<div style="page-break-after: always;"></div>

Wait for the band to arrive:)

# After the band arrives

* Be nice, connect with them personally.
* Help them with what ever they ask.

* **Ask them to set instrument controls to neutral**
    * Some instruments have equalizers on them, ask the owner to turn it off, or set it to "flat".
    * Some instruments have volume controls on them, ask the owner to set it to neutral, or middle.
    * And ask the owners of the instruments, not to change any of those during performing.

* **Check vocalist-microphone alignments**
    * Very important!
    * Align height and direction, so that the microphone is in line with the mouth, and points towards them. Ideally it
      points bottom up.
    * Meanwhile, keep it in a way so that the sound from the monitor would hit the microphone from the back as much as
      possible.

<div style="page-break-after: always;"></div>

## Gain staging

Go through:

* **Vocal mics 1 to 6**, and
* **Instruments 1 to 5**

and for each used channel, check & adjust the gain setting. No need to gain-stage the drums and the keyboard.

1. **Have input signal**: In order to set the gain level, we must have input, e.g. they must sing or play the
   instrument.
    * You can do this while they are playing already.
    * Or ask them one-by-one to play or sing from their lowest to highest volume.
        * You only really care about their highest volume levels, but asking from lowest to highest usually helps them
          in producing more precise results.
    * Make sure to set the gain only when a normal, regular input is coming through. This is very important.

    <img src="assets/console/gainstaging.png" height="170"/>

2. Press **{Layers/VOCAL}** OR **{Layers/INSTR}**: to select the right layer.
3. Press **{Channel X/SELECT}**: to select the channel for which you want to set the gain.
    * See image, point #1.
4. Watch **{Channel X/METER}**.
    * See image, point #2.
5. Aim for **-18db:** When the input is around its normal level, it should be around the -18db mark.
    * Normal level: when the singer sings normally, not far from the mic, not shying away, and when not shouting strong.
      The same goes for instruments.
6. Adjust the **{GAIN}** knob at the console's top left corner if needed.
    * Do it until the signal jumps around -18 db.

7. Repeat this section for the next vocal or instrument channel that is in use, or continue if finished.

**Channel gain should not be changed after this initial setup.**

<div style="page-break-after: always;"></div>

## Save the scene

On the console:

* Press **{Scenes/VIEW}**.
* Turn **{Knobs/Save}** to scroll to the "**Service**" (without the "READONLY" part!) scene.
* Press **{Knobs/SAVE}**: to save.
* Press **{Knobs/BACKSPACE}**: to remove "READONLY" from the name if needed.
* Press **{Knobs/SAVE}**.
* Press **{Knobs/CONFIRM}**.

## During the rehearsal

* Set up a mix (with the 8 group faders on the right) that sounds right.
    * The lead singer should be a bit louder than the other vocalists.
* **PUT YOUR HEAD OUT** and listen!

* If you have capacity, go up to the stage while they sing, and check if:
    * Everything is balanced, everyone hears everyone.
    * Nothing is too loud.

* Isn't the stage too loud?
    * Sometimes mute the MAIN channel, to see if the stage is too loud or if one source is overpowering the others on
      the stage.
    * If an instrument or vocalist fills the room just from the monitors, ask them or help them adjust it.
    * Don't mute the room for long, it disturbs the band. Mute, check, unmute.
* Is the volume below the limit on the SPL meter?
* Did you ask the instrument players to reset their eq/volume levels?
* Do you hear all instruments?
* Do you hear all vocalists?
* Do you hear the drum (from the speakers!?)
* Does all the singers sing into the microphone?
    * Are they far away from it, or angled in relation to it?
* Do they need any help?

<div style="page-break-after: always;"></div>

### If a vocalist sounds off-key or unexpected

Our singers are quite good and checked, so if they sound bad,
that is most likely due to them not hearing themselves correctly.

To solve this: go up on the stage and check the monitor volume levels.

Your goal is so that they would be a bit more present in the stage-monitor mix:

* Either increase the overall monitor level
* Or increase their level in the monitor
* Or lower something that is too loud

An alternative reason can be:

* An overworking compressor on the channel.
* A too high (or low) low-cut.
* An unfortunate equalizer setting.


# After the rehearsal

## Save the scene

On the console:

* Press **{Scenes/VIEW}**.
* Turn **{Knobs/Save}** to scroll to the "**Service**" (without the "READONLY" part!) scene.
* Press **{Knobs/SAVE}**: to save.
* Press **{Knobs/BACKSPACE}**: to remove "READONLY" from the name if needed.
* Press **{Knobs/SAVE}**.
* Press **{Knobs/CONFIRM}**.

## Close up

* SPL METER:
    * Turn off the SPL meter.
    * Put it back onto the shelf above the console.

* Follow the "[Turning off the audio system](../labels/turningoff.pdf)" guide posted on the mixer door.
