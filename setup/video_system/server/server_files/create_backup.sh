#!/bin/bash
# Creates a timestamped backup of:
#   - PostgreSQL database (schema + data, compressed)
#   - n8n workflows, credentials (decrypted), and entities via CLI
#   - .env file
#   - All docker_volumes (except postgres, which is covered by pg_dump)
#
# Restore hints:
#   Postgres:     gunzip -c postgres.sql.gz | docker compose exec -T postgres psql -U $POSTGRES_USER $POSTGRES_DB
#   Workflows:    docker compose exec -T n8n n8n import:workflow --separate --input=/restore/workflows/
#   Credentials:  docker compose exec -T n8n n8n import:credentials --separate --input=/restore/credentials/
#   Volumes:      tar -xzf docker_volumes.tar.gz -C /path/to/deploy_nas/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# ── Load environment ────────────────────────────────────────────────────────────
if [ ! -f .env ]; then
    echo "Error: .env file not found."
    exit 1
fi
set -a; source .env; set +a

# ── Prepare destination ─────────────────────────────────────────────────────────
TIMESTAMP=$(date +%Y-%m-%d_%H%M%S)
BACKUP_DIR="$SCRIPT_DIR/backups/$TIMESTAMP"

mkdir -p "$BACKUP_DIR/n8n/workflows"
mkdir -p "$BACKUP_DIR/n8n/credentials"
mkdir -p "$BACKUP_DIR/n8n/entities"

log() { echo "[$(date +%H:%M:%S)] $*"; }

log "Backup started → $BACKUP_DIR"

# ── 1. PostgreSQL ───────────────────────────────────────────────────────────────
log "Dumping PostgreSQL..."
docker compose exec -T postgres \
    pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
    | gzip > "$BACKUP_DIR/postgres.sql.gz"
log "PostgreSQL done ($(du -sh "$BACKUP_DIR/postgres.sql.gz" | cut -f1))"

# ── 2. n8n workflows ────────────────────────────────────────────────────────────
# --backup sets --all --pretty --separate (one JSON file per workflow)
log "Exporting n8n workflows..."
N8N_TMP=/tmp/n8n_backup_$$
docker compose exec -T n8n sh -c "
    rm -rf  $N8N_TMP/workflows $N8N_TMP/credentials $N8N_TMP/entities
    mkdir -p $N8N_TMP/workflows $N8N_TMP/credentials $N8N_TMP/entities
    n8n export:workflow --backup --output=$N8N_TMP/workflows
"
docker cp "n8n:$N8N_TMP/workflows/." "$BACKUP_DIR/n8n/workflows/"
log "Workflows done ($(ls "$BACKUP_DIR/n8n/workflows/" | wc -l) files)"

# ── 3. n8n credentials (decrypted) ─────────────────────────────────────────────
# --backup sets --all --pretty --separate; --decrypted removes encryption
log "Exporting n8n credentials..."
docker compose exec -T n8n \
    n8n export:credentials --backup --decrypted --output="$N8N_TMP/credentials"
docker cp "n8n:$N8N_TMP/credentials/." "$BACKUP_DIR/n8n/credentials/"
log "Credentials done ($(ls "$BACKUP_DIR/n8n/credentials/" | wc -l) files)"

# ── 4. n8n entities (tags, variables, data tables, etc.) ───────────────────────
log "Exporting n8n entities..."
docker compose exec -T n8n \
    n8n export:entities --outputDir="$N8N_TMP/entities"
docker cp "n8n:$N8N_TMP/entities/." "$BACKUP_DIR/n8n/entities/"
docker compose exec -T n8n rm -rf "$N8N_TMP"
log "Entities done ($(ls "$BACKUP_DIR/n8n/entities/" | wc -l) files)"

# Decrypt entity jsonl files (AES-256-CBC, MD5 KDF — n8n default)
log "Decrypting n8n entities..."
ENTITIES_ZIP="$BACKUP_DIR/n8n/entities/entities.zip"
ENTITIES_TMP="$BACKUP_DIR/n8n/entities_tmp"
mkdir -p "$BACKUP_DIR/n8n/entities_decrypted"
unzip "$ENTITIES_ZIP" -d "$ENTITIES_TMP" > /dev/null
for enc_file in "$ENTITIES_TMP/"*.jsonl; do
    [ -f "$enc_file" ] || continue
    fname=$(basename "$enc_file")
    openssl enc -d -aes-256-cbc -a -A -pass "pass:$N8N_ENCRYPTION_KEY" -md md5 \
        -in "$enc_file" -out "$BACKUP_DIR/n8n/entities_decrypted/$fname" 2>/dev/null \
        || { log "  Warning: could not decrypt $fname (skipping)"; rm -f "$BACKUP_DIR/n8n/entities_decrypted/$fname"; }
done
rm -rf "$ENTITIES_TMP"
log "Entities decrypted ($(ls "$BACKUP_DIR/n8n/entities_decrypted/" | wc -l) files)"

# ── 5. .env ─────────────────────────────────────────────────────────────────────
log "Backing up .env..."
cp "$SCRIPT_DIR/.env" "$BACKUP_DIR/.env"
log ".env done"

# ── 6. docker_volumes (everything except postgres) ──────────────────────────────
# Postgres data is already captured by pg_dump above — no need to duplicate it.
# sudo is required because volume files are owned by various container users.
log "Compressing docker_volumes (excluding postgres data)..."
sudo tar -czf "$BACKUP_DIR/docker_volumes.tar.gz" \
    --exclude="docker_volumes/postgres" \
    -C "$SCRIPT_DIR" \
    docker_volumes/
log "docker_volumes done ($(du -sh "$BACKUP_DIR/docker_volumes.tar.gz" | cut -f1))"

# ── Summary ─────────────────────────────────────────────────────────────────────
ln -sfn "$BACKUP_DIR" "$SCRIPT_DIR/backups/latest"

echo ""
log "Backup complete."
echo "  Path:  $BACKUP_DIR"
echo "  Size:  $(du -sh "$BACKUP_DIR" | cut -f1)"
echo "  Link:  backups/latest"
