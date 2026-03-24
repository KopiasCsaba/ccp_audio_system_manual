#!/usr/bin/env python3
"""Video processor - converts files by pattern."""
import logging, re, subprocess, sys
from pathlib import Path

# ============== CONFIGURATION ==============
WORK_FOLDER = "/mnt"

CONVERT_PATTERNS = [r"[^.].*CAM 1.*\.mp4$", r"[^.].*CAM 2.*\.mp4$", r"[^.].*CAM 3.*\.mp4$"]

# FFMPEG_CMD = '''ffmpeg -i "{input}" \
#   -y -c:v libx264 -preset fast -crf 23 -maxrate 5000k -bufsize 10000k \
#   -x264-params rc-lookahead=60:threads=0:thread-frames=2 \
#   -g 60 -keyint_min 60 -sc_threshold 0 -r 30 \
#   -c:a aac -b:a 128k -movflags +faststart "{output}"'''

FFMPEG_CMD = '''ffmpeg -i "{input}" \
  -y -c:v libx264 -crf 26 -bufsize 10000k \
  -x264-params rc-lookahead=60:threads=0:aq-mode=3 \
  -g 250 -keyint_min 25  -r 30 -tune film  -preset slow  \
  -c:a aac -b:a 128k -movflags +faststart "{output}"'''


# ============================================

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(message)s",
    handlers=[
        logging.FileHandler(f"{WORK_FOLDER}/video_processor.log"),
        logging.StreamHandler()
    ]
)
log = logging.info

def matches(name, patterns):
    return any(re.match(p, name, re.IGNORECASE) for p in patterns)

def get_files(folder):
    return [f for f in folder.rglob("*") if f.is_file()
            and not f.name.endswith('.log')
            and '_converted' not in f.name
            and '_converting.tmp' not in f.name]

def process():
    folder = Path(WORK_FOLDER)
    if not folder.exists():
        return log(f"Folder missing: {WORK_FOLDER}")

    files = get_files(folder)
    log(f"Processing {len(files)} files (recursive)")

    for f in files:
        if matches(f.name, CONVERT_PATTERNS):
            out = f.with_stem(f"{f.stem}_converted")
            if out.exists():
                log(f"SKIP (already done): {f.relative_to(folder)}")
                continue
            tmp = f.with_stem(f"{f.stem}_converting.tmp")
            log(f"CONVERT: {f.relative_to(folder)}")
            result = subprocess.run(FFMPEG_CMD.format(input=f, output=tmp), shell=True)
            if result.returncode == 0:
                tmp.rename(out)
                log(f"  Done: {out.relative_to(folder)}")
            else:
                log(f"  Error: ffmpeg returned {result.returncode}")
                if tmp.exists(): tmp.unlink()

    log("Complete")

if __name__ == "__main__":
    print("video_processor.py starting")
    if "--debug" in sys.argv:
        folder = Path(WORK_FOLDER)
        files = get_files(folder)
        print(f"Found {len(files)} files total")
        for f in files[:20]:
            m = matches(f.name, CONVERT_PATTERNS)
            print(f"  {'MATCH' if m else '     '} {f.name}")
        if len(files) > 20: print(f"  ... and {len(files)-20} more")
        sys.exit(0)
    process()
