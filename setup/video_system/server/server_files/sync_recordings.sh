#!/bin/bash
#set -x
# Sync recordings from CalvaryAtem SMB share to local storage
# Only copies: CAM 1, CAM 2, CAM 3, and non-CAM mp4 files
# Excludes hidden files (starting with .)

# Configuration
SOURCE_IP="${ATEM_IP:-192.168.2.201}"
SMB_SHARE="${SMB_SHARE:-//${SOURCE_IP}/CalvaryAtem}"
SMB_USER="${SMB_USER:-guest}"
SMB_PASS="${SMB_PASS:-guest}"
SMB_WORKGROUP="${SMB_WORKGROUP:-WORKGROUP}"


PREFIX="${1:?Usage: $0 PREFIX TARGET_DIR}"
TARGET_DIR="${2:?Usage: $0 PREFIX TARGET_DIR}"
DEST_DIR="$TARGET_DIR"

BANDWIDTH_LIMIT="${BANDWIDTH_LIMIT:-50000}"  # KiB/s (rsync unit); 10240 = 10 MB/s
MOUNT_POINT="/media/source"
NOTIFY_URL="${NOTIFY_URL:-}"

DEBUG=""
#DEBUG="-avni"

MOUNT_RETRIES=1
MOUNT_RETRY_DELAY=15

# Ping with timeout: 3 attempts, 2 second timeout per attempt
if ! ping -c 3 -W 2 "$SOURCE_IP" > /dev/null 2>&1; then
    echo "$(date) - ATEM($SOURCE_IP) is not reachable this time. Will try again later..."
    exit 0
fi


mkdir -p "$MOUNT_POINT" 2>/dev/null || true;

ensure_mounted() {
    # If already mounted, check it's not stale
    if mountpoint -q "$MOUNT_POINT"; then
      echo "$(date) Checking mount ..."
        if ! timeout 10 ls "$MOUNT_POINT" > /dev/null 2>&1; then
            echo "$(date) - Stale mount detected, unmounting..."
            umount -l "$MOUNT_POINT" 2>/dev/null || true
            sleep 2
        else
            return 0
        fi
    fi

    for i in $(seq 1 $MOUNT_RETRIES); do
        echo "$(date) - Mounting $SMB_SHARE (attempt $i/$MOUNT_RETRIES)"
        if mount -t cifs "$SMB_SHARE" "$MOUNT_POINT" \
            -o username="$SMB_USER",password="$SMB_PASS",workgroup="$SMB_WORKGROUP",uid=$(id -u),gid=$(id -g); then
            echo "$(date) - Mounted successfully"
            return 0
        fi
        if [ $i -lt $MOUNT_RETRIES ]; then
            echo "$(date) - Mount failed, retrying in ${MOUNT_RETRY_DELAY}s..."
            sleep "$MOUNT_RETRY_DELAY"
        fi
    done

    echo "$(date) - ERROR: Failed to mount $SMB_SHARE after $MOUNT_RETRIES attempts, aborting"
    exit 1
}

notify() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M')
    local body="${timestamp}\n$1"
    echo "NOTIFY: $body"
    [ -z "$NOTIFY_URL" ] && return 0
    curl -s -o /dev/null -X POST "$NOTIFY_URL" -H "Content-Type: text/plain" --data-raw "$body"
}

# Run a command; on failure remount and retry once
run_resilient() {
    "$@"
    local rc=$?
    if [ $rc -ne 0 ]; then
        echo "$(date) - Command failed (exit $rc), remounting and retrying..."
        umount -l "$MOUNT_POINT" 2>/dev/null || true
        sleep 2
        ensure_mounted
        "$@" || { echo "$(date) - ERROR: Command failed again after remount, aborting"; exit 1; }
    fi
}

ensure_mounted

echo "$(date) - Starting sync from $MOUNT_POINT to $DEST_DIR"


# Create exclude list of files modified in the past 2 minutes
echo "$(date) - Building exclude list of recently modified files..."
find "$MOUNT_POINT" -type f -mmin -2 -printf '%P\n' > /tmp/recent_files.txt
EXCLUDE_COUNT=$(wc -l < /tmp/recent_files.txt)
echo "$(date) - Excluding $EXCLUDE_COUNT recently modified files from sync"

# Rsync with filters:
# - Include CAM 1, CAM 2, CAM 3 mp4 files (not starting with .)
# - Include mp4 files without CAM in name (not starting with .)
# - Exclude everything else
# - Exclude files modified in the past 2 minutes (via --exclude-from)
# - Prune empty directories from transfer (-m)
mkdir -p "$DEST_DIR"

RSYNC_FILTERS=(
    --bwlimit="$BANDWIDTH_LIMIT"
    --size-only
    --exclude-from=/tmp/recent_files.txt
    --filter="+ /${PREFIX}*/"
    --filter="- /*/"
    --include='*/'
    --include='[!.]*CAM 1*.mp4'
    --include='[!.]*CAM 2*.mp4'
    --include='[!.]*CAM 3*.mp4'
    --include='[!.]*CAM 6*.mp4'
    --exclude='*CAM*.mp4'
    --include='[!.]*.mp4'
    --include='*.drp'
    --include='~sync_done'
    --exclude='*'
)

# Dry-run to check if anything needs syncing
DRY_STATS=$(rsync -rvm --dry-run --stats "${RSYNC_FILTERS[@]}" "$MOUNT_POINT/" "$DEST_DIR/" 2>/dev/null)
PENDING=$(echo "$DRY_STATS" | grep "Number of regular files transferred:" | awk '{print $NF}')

echo "$(date) - Syncing files... (pending: ${PENDING:-0})"
if [ "${PENDING:-0}" -gt 0 ]; then
    notify "Syncing ${PENDING:-0} files :loading:"
fi

run_resilient rsync -rvm $DEBUG --progress "${RSYNC_FILTERS[@]}" \
    "$MOUNT_POINT/" "$DEST_DIR/" | tee /tmp/rsync_files.log

echo "$(date) - Videos synced."

OLD_FILES=$(run_resilient find "$MOUNT_POINT" -type f -mtime +14 -print -delete | wc -l)
echo "$(date) - Deleted $OLD_FILES files older than 2 weeks"

EMPTY_DIRS=$(run_resilient find "$MOUNT_POINT" -mindepth 1 -type d -empty -print -delete | wc -l)
echo "$(date) - Deleted $EMPTY_DIRS empty folders"

# Delete unwanted CAM files (CAM 4-8) from source that are older than 3 days.
CAM_FILES=$(run_resilient find "$MOUNT_POINT" -type f  -mtime +3 \( \
    -name "*CAM 4*" -o \
    -name "*CAM 5*" -o \
    -name "*CAM 7*" -o \
    -name "*CAM 8*" \
\) -print -delete | wc -l)
echo "$(date) - Deleted $CAM_FILES unneeded CAM 4,5,7,8 files older than 3 days from ATEM"

AUDIO_DIRS=$(run_resilient find "$MOUNT_POINT" -type d -name "Audio Source Files" -print | wc -l)
run_resilient find "$MOUNT_POINT" -type d -name "Audio Source Files" -exec rm -rf {} + 2>/dev/null || true
echo "$(date) - Deleted $AUDIO_DIRS 'Audio Source Files' directories"

echo "$(date)  Running chmod on destination directories"
chmod 0777 -R "$DEST_DIR"


if [ "${PENDING:-0}" -gt 0 ]; then
    notify "Synchronisation finished!"
fi

