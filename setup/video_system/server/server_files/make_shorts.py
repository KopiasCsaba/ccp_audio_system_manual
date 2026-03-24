#!/usr/bin/env python3
import logging
import os
import re
import subprocess
import sys

import requests

WEBHOOK_URL = os.environ.get("SHORTS_WEBHOOK_URL")

_SAFE_ID_RE = re.compile(r'^[\w\-]+$')


def find_target_folders(base):
    for root, dirs, files in os.walk(base):
        if os.path.basename(root) == "Video ISO Files":
            if "shorts" not in dirs and ".noshorts" not in files:
                yield root


def setup_logger(shorts_dir):
    os.makedirs(shorts_dir, exist_ok=True)
    log_path = os.path.join(shorts_dir, "shorts.log")
    logger = logging.getLogger(shorts_dir)
    if logger.handlers:
        return logger
    logger.setLevel(logging.INFO)
    logger.propagate = False
    fh = logging.FileHandler(log_path)
    fh.setFormatter(logging.Formatter("%(asctime)s %(levelname)s %(message)s"))
    ch = logging.StreamHandler(sys.stdout)
    ch.setFormatter(logging.Formatter("%(message)s"))
    logger.addHandler(fh)
    logger.addHandler(ch)
    return logger


def get_shorts(folder_name):
    resp = requests.get(WEBHOOK_URL, params={"folder": folder_name}, timeout=30)
    resp.raise_for_status()
    data = resp.json()
    if not isinstance(data, list) or not data:
        raise ValueError(
            "Unexpected response shape: expected non-empty list, got %s len=%s"
            % (type(data).__name__, len(data) if isinstance(data, list) else "N/A")
        )
    first = data[0]
    if first.get("type") != "ok":
        raise ValueError("Response type is not ok: got type=%r" % first.get("type"))
    content = first.get("content", [])
    if not isinstance(content, list):
        raise ValueError("content is not a list: got %s" % type(content).__name__)
    required = {"id", "in_secs", "out_secs", "recording_index"}
    return [item for item in content if required.issubset(item.keys())]


def make_short(vif_path, folder_name, item, log):
    idx = item["recording_index"]
    if idx is None:
        log.info("  Skipping id=%s: recording_index is null", item['id'])
        return
    if not isinstance(idx, int):
        log.warning("  Skipping id=%s: recording_index is not an int (%r)", item['id'], idx)
        return
    idx_str = f"{idx:02d}"
    in_secs = item["in_secs"]
    out_secs = item["out_secs"]
    id_ = item["id"]

    if not isinstance(in_secs, (int, float)) or not isinstance(out_secs, (int, float)):
        log.warning("  Skipping id=%s: in_secs/out_secs not numeric", id_)
        return
    if out_secs <= in_secs:
        log.warning("  Skipping id=%s: out_secs (%s) <= in_secs (%s)", id_, out_secs, in_secs)
        return
    if not _SAFE_ID_RE.match(str(id_)):
        log.warning("  Skipping id=%s: unsafe characters in id", id_)
        return

    input_file = os.path.join(vif_path, f"{folder_name} CAM 1 {idx_str}_converted.mp4")
    if not os.path.exists(input_file):
        log.warning("  Input not found: %s", input_file)
        return

    shorts_dir = os.path.join(vif_path, "shorts")
    output_file = os.path.join(shorts_dir, f"{folder_name} CAM 1 {idx_str} id{id_} in{in_secs} out{out_secs}.mp4")

    if not os.path.realpath(output_file).startswith(os.path.realpath(shorts_dir) + os.sep):
        log.error("  Skipping id=%s: output path escapes shorts_dir", id_)
        return

    duration = out_secs - in_secs
    cmd = ["ffmpeg", "-loglevel", "error", "-ss", str(in_secs), "-i", input_file,
           "-t", str(duration), "-c:v", "copy", "-c:a", "copy", "-y", output_file]
    log.info("  Running: %s", ' '.join(cmd))
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        log.error("  ffmpeg failed (exit %d): %s", result.returncode, result.stderr.strip())
        return
    log.info("  Created: %s", os.path.basename(output_file))


def main():
    if not WEBHOOK_URL:
        print("ERROR: SHORTS_WEBHOOK_URL is not set", file=sys.stderr)
        sys.exit(1)
    if not WEBHOOK_URL.startswith(("http://", "https://")):
        print("ERROR: SHORTS_WEBHOOK_URL must be an http(s) URL", file=sys.stderr)
        sys.exit(1)

    base = os.environ.get("SHORTS_BASE_PATH", ".")
    for vif_path in find_target_folders(base):
        folder_name = os.path.basename(os.path.dirname(vif_path))
        print(f"Processing: {vif_path} (folder={folder_name})")

        try:
            items = get_shorts(folder_name)
        except requests.exceptions.RequestException as e:
            print(f"  ERROR: API request failed: {e}", file=sys.stderr)
            continue
        except Exception as e:
            print(f"  ERROR: fetching shorts: {e}", file=sys.stderr)
            continue

        if not items:
            noshorts = os.path.join(vif_path, ".noshorts")
            try:
                with open(noshorts, "w"):
                    pass
                print("  No shorts, created .noshorts")
            except OSError as e:
                print(f"  ERROR: Could not create .noshorts: {e}", file=sys.stderr)
            continue

        shorts_dir = os.path.join(vif_path, "shorts")
        dir_existed = os.path.exists(shorts_dir)
        try:
            log = setup_logger(shorts_dir)
        except Exception as e:
            print(f"  ERROR: Cannot set up logger at {shorts_dir}: {e}", file=sys.stderr)
            continue

        if not dir_existed:
            try:
                subprocess.run(["chmod", "-R", "0777", shorts_dir], check=True)
            except subprocess.CalledProcessError as e:
                log.warning("  chmod failed on %s: %s", shorts_dir, e)

        for item in items:
            try:
                make_short(vif_path, folder_name, item, log)
            except Exception as e:
                log.error("  Unexpected error processing item %s: %s", item.get('id', '?'), e)


if __name__ == "__main__":
    print("make_shorts.py starting")
    main()
