<h1>Video Editing</h1>

<!-- TOC -->
* [1) Download the recording](#1-download-the-recording)
* [2) Concatenate if needed](#2-concatenate-if-needed)
* [3) Trim beginning and end if needed](#3-trim-beginning-and-end-if-needed)
  * [Cut points to be aware:](#cut-points-to-be-aware)
* [4) Exporting a frame for thumbnail](#4-exporting-a-frame-for-thumbnail)
* [5) Upload the recording](#5-upload-the-recording)
* [6) Upload the Thumbnail](#6-upload-the-thumbnail)
<!-- TOC -->

# 1) Download the recording

From [StreamPcObsRecordings](https://drive.google.com/drive/folders/1hNNs13uH2axNPDnkZgHyR10jpfO7UVrc)
# 2) Concatenate if needed

Concatenation is a serious sickness, that happens to video files. Just kidding.
So that is when you join multiple videos together.
Sometimes, technical issues might break up the recording into multiple parts. Thats when you need to combine them first.

Use the free, open-source tool called [LosslessCut](https://github.com/mifi/lossless-cut), to edit the video.
Learn how to install LosslessCut [here.](installing_losslesscut.md)


1. Start [LosslessCut](installing_losslesscut.md)
2. File -> Open
3. Select the video files
4. Tools -> Merge/Concatenate video files
5. Press [MERGE]

The video is saved next to the input videos, and in this case, you want to use that in the next steps, instead of the separate parts.


# 3) Trim beginning and end if needed

## Cut points to be aware:
* Beginning: Before the person doing the announcements just about to start to speak
* Breaks: Bible-school classes usually have a long break in the middle.
* End: After the "Thank you for joining us" end screen, or after the blessing prayer from 2Cor13:14.

1. Start [LosslessCut](installing_losslesscut.md)
2. File -> Open
3. Select the video file
4. Mark regions:
    * Mark IN point
        * Move the playhead to the position where you want the IN point to be.
        * Fine-tune the alignment with the keyframe buttons.
            * <img src="assets/video/llc-keyframe-buttons.png">
        * Mark the beginning by pressing the "Start current segment" button.
            * <img src="assets/video/llc-buttons-in.png">

    * Mark OUT point
        * Move the playhead to the position where you want the OUT point to be.
        * Fine-tune the alignment with the keyframe buttons.
            * <img src="assets/video/llc-keyframe-buttons.png">
        * Mark the end by pressing the "End current segment" button.
            *  <img src="assets/video/llc-buttons-out.png">

You can have multiple regions, if you want to cut something out, but most of the time we only trim the beginning and the
end.

You should reach something like this:

<img src="assets/video/llc-regions.png">

5. Make sure, that the top right selection is "Merge cuts".
6. Press the "Export+Merge" button.

The file will be saved next to where you have downloaded the video.

# 4) Exporting a frame for thumbnail

If you need/want to make a thumbnail out of a frame in the video, follow these steps.

* Move the playhead to the frame you want to export
* Press the little camera icon in the bottom right corner

<img src="assets/video/thumbexport.png">

The file will be saved next to where you have downloaded the video.

# 5) Upload the recording

We archive our recordings together with the thumbnails regularly from google drive, thats why
we ask you to upload the edited files too.

So, upload the edited recording
to [EditedRecordings](https://drive.google.com/drive/folders/1uiSQAJTFtMKRcx1BCm3R-SwR9kuvnIYf).

<b>Naming</b>:

Please use the following file naming system:

Template:

`YYYY-MM-DD $TITLE - $PASSAGE - $PASTOR_NAME`

Example:

`2023-07-30 Right with God - Romans 3:9-31 - Pastor Stephen Clarke`

# 6) Upload the Thumbnail

If you made a thumbnail, please also upload that to
the [thumbnails](https://drive.google.com/drive/folders/1G_yGUalItjvr9RIatlAt7c1_WIkqtqAj) folder.
