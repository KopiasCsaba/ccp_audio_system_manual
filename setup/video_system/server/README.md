<h1>Table of contents</h1>

<!-- TOC -->
* [Configuration](#configuration)
* [Services](#services)
* [Management scripts](#management-scripts)
  * [create_backup.sh](#create_backupsh)
  * [manage.sh](#managesh)
* [Postprocessing scripts](#postprocessing-scripts)
  * [sync_recordings.sh](#sync_recordingssh)
    * [Purpose](#purpose)
    * [Usage](#usage)
    * [What it does](#what-it-does)
    * [Key environment variables](#key-environment-variables)
  * [video_processor.py](#video_processorpy)
    * [Purpose](#purpose-1)
    * [What it does](#what-it-does-1)
    * [Debug mode](#debug-mode)
  * [make_shorts.py](#make_shortspy)
    * [Purpose](#purpose-2)
    * [What it does](#what-it-does-2)
    * [Environment variables](#environment-variables)
    * [API contract](#api-contract)
<!-- TOC -->

# Configuration
See files in [server_files](server_files).

The idea is that everything is contained in those files, wherever `docker compose` is available, we can start our services,
minimal server-level configuration is needed, all is self-contained in here.

# Services
* [Restreamer](restreamer)
* [N8N](n8n)
* [Companion](companion)


# Management scripts


## create_backup.sh
Creates a full backup of all services and their data into the backups/ folder.


## manage.sh
Tool to manage all our containers.

```bash
$ ./manage.sh 
Usage: ./manage.sh {start|stop|restart|reload|logs|status|shell|down} [service_name]

Commands:
  start   - Start services in detached mode (optional: specify service name)
  stop    - Stop services (optional: specify service name)
  restart - Restart services (optional: specify service name)
  reload  - Rebuild and recreate services (optional: specify service name)
  logs    - Show logs (optional: specify service name)
  status  - Show service status
  shell   - Open shell in container (requires service name)
  down    - Stop and remove services (optional: specify service name)

Services:
  reverse_proxy_webserver
  video-processor
  atem-nas-sync
  companion
  postgres
  n8n
  restreamer
```


---

# Postprocessing scripts

These three scripts form the post-service recording pipeline. They run inside Docker containers defined in [docker-compose.yml](server_files/docker-compose.yml) and handle everything from pulling raw footage off the ATEM to producing short clips ready for publishing.

Overview:
```
ATEM → [sync_recordings.sh] → NAS → [video_processor.py] → [make_shorts.py] → shorts/
```

---

## sync_recordings.sh

**Container:** `atem-nas-sync` — runs every 60 seconds with `flock` to prevent overlapping executions.

### Purpose

Copies raw MP4 recordings from the ATEM Mini's SMB share to the NAS, and keeps the ATEM's storage clean by removing old or unwanted files.

### Usage

```bash
sync_recordings.sh <PREFIX> <TARGET_DIR>
```

| Argument | Example | Description |
|---|---|---|
| `PREFIX` | `CCP_` | Only sync folders whose name starts with this prefix |
| `TARGET_DIR` | `/mnt/recordings/ccp` | Local destination directory |

In production the script is called multiple times — once per preset:

```bash
sync_recordings.sh CCP_     /mnt/recordings/ccp
sync_recordings.sh CHINESE_ /mnt/recordings/chinese
```

### What it does

1. **Reachability check** — pings the ATEM IP 3 times (2 s timeout each). Exits cleanly if unreachable; the loop will retry on the next cycle.
2. **SMB mount** — mounts `//ATEM_IP/CalvaryAtem` via CIFS to `/media/source`. Handles stale mounts and retries.
3. **Recent-file exclusion** — files modified within the last minute are excluded from the transfer to avoid copying recordings that are still being written.
4. **Filtered rsync** — only transfers the files that are needed for editing and processing:
   - `CAM 1`, `CAM 2`, `CAM 3`, `CAM 6` MP4 files (not hidden)
   - Any other non-CAM MP4 files (program output, etc.)
   - `.drp` project files
   - Only within folders matching the configured prefix
5. **Notifications** — if more than one file is pending, posts a status message to the configured webhook URL (n8n) at sync start and completion.
6. **ATEM storage cleanup** (runs on the mounted source after sync):
   - Deletes all files older than 14 days
   - Deletes `CAM 4`, `5`, `7`, `8` files older than 3 days (these cameras are not used for editing)
   - Removes `Audio Source Files` directories
   - Removes empty directories

### Key environment variables

| Variable | Default | Description |
|---|---|---|
| `ATEM_IP` | `192.168.2.201` | IP address of the ATEM Mini |
| `SMB_SHARE` | `//ATEM_IP/CalvaryAtem` | Full SMB path |
| `SMB_USER` / `SMB_PASS` | `guest` / `guest` | SMB credentials |
| `BANDWIDTH_LIMIT` | `50000` KiB/s | rsync bandwidth cap (~50 MB/s) |
| `NOTIFY_URL` | _(empty)_ | Webhook URL for sync notifications |

---

## video_processor.py

**Container:** `video-processor` — runs daily at night.

### Purpose

Re-encodes the raw camera recordings into a consistent, web-friendly H.264 format. The converted files are what all downstream tools (including `make_shorts.py`) use.

### What it does

1. Recursively scans `/mnt` for MP4 files matching any of the camera patterns:
   - `CAM 1` — main camera
   - `CAM 2` — projection / slides
   - `CAM 3` — pulpit
2. Skips files that are already converted (filename contains `_converted`) or are in the middle of conversion (`_converting.tmp`).
3. Skips files inside `shorts/` subdirectories and files inside `.~tmp~/` folders (incomplete rsync transfers).
4. For each matching file, runs `ffmpeg` to produce a `<original_name>_converted.mp4` alongside the source:
   - Codec: H.264 (`libx264`), CRF 26, `slow` preset
   - Frame rate: 30 fps, keyframe interval tuned for seeking
   - Audio: AAC 128 kbps
   - `+faststart` flag for immediate web playback
5. During encoding, writes to a `.tmp` file first; only renames to the final `_converted` name on success. This ensures no partially encoded file is ever mistaken for a completed one.
6. Logs all activity to `/mnt/video_processor.log` and stdout.

### Debug mode

```bash
python video_processor.py --debug
```

Prints the first 20 matched files with their match status and exits without encoding anything. Useful for verifying filter patterns before a full run.

---

## make_shorts.py

**Container:** `video-processor` — runs daily, immediately after `video_processor.py`.

### Purpose

Cuts short clips from converted recordings based on timecodes retrieved from a remote API (n8n webhook). This automates the creation of highlight or sermon clips for social media publishing.

### What it does

1. Walks the base path (`SHORTS_BASE_PATH`) looking for `Video ISO Files` directories that:
   - Do not already have a `shorts/` subdirectory (not yet processed), and
   - Do not have a `.noshorts` sentinel file (explicitly marked as having no clips).
2. For each qualifying directory, queries `SHORTS_WEBHOOK_URL` with the parent folder name (e.g. `CCP_2024-11-10`). The API returns a list of clip definitions.
3. For each clip definition received:
   - Looks up the corresponding `_converted.mp4` file by `recording_index` (zero-padded, e.g. `01`).
   - Runs `ffmpeg` with stream copy (no re-encoding) to extract the segment between `in_secs` and `out_secs`.
   - Saves the output as `<folder> CAM 1 <idx> id<id> in<in> out<out>.mp4` inside a `shorts/` subdirectory.
4. If the API returns no clips for a folder, creates a `.noshorts` file so the folder is skipped on future runs.
5. Logs per-folder activity to `shorts/shorts.log` inside each processed directory.

### Environment variables

| Variable | Required | Description |
|---|---|---|
| `SHORTS_WEBHOOK_URL` | Yes | Full HTTP(S) URL of the n8n webhook that returns clip definitions |
| `SHORTS_BASE_PATH` | No (default: `.`) | Root directory to search for `Video ISO Files` folders |

### API contract

The webhook must return a JSON array. The first element must have `"type": "ok"` and a `"content"` array where each item contains:

| Field | Type | Description |
|---|---|---|
| `id` | string/int | Unique clip identifier (alphanumeric + hyphens only) |
| `recording_index` | int | Which recording file to use (maps to the `_NN_converted.mp4` filename index) |
| `in_secs` | number | Clip start time in seconds |
| `out_secs` | number | Clip end time in seconds |