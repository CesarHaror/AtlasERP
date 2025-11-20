#!/usr/bin/env bash
set -euo pipefail

# backup_and_restore_staging.sh
# Usage (example):
# SRC_DATABASE_URL=postgres://user:pass@src-host:5432/sourcedb \
# STAGING_DATABASE_URL=postgres://user:pass@staging-host:5432/stagingdb \
# bash backend/scripts/backup_and_restore_staging.sh

if [[ -z "${SRC_DATABASE_URL:-}" || -z "${STAGING_DATABASE_URL:-}" ]]; then
  cat <<USAGE
Usage:
  SRC_DATABASE_URL=postgres://user:pass@host:port/sourcedb \
  STAGING_DATABASE_URL=postgres://user:pass@host:port/stagingdb \
  bash backend/scripts/backup_and_restore_staging.sh

Notes:
  - It's safer to use a .pgpass file or environment variables rather than embedding passwords.
  - Test this script on a copy of your DB or in an isolated environment before running in production.
  - The script creates a custom-format dump (*.dump) and restores it to the staging DB.
USAGE
  exit 1
fi

TS=$(date +%Y%m%d_%H%M%S)
DUMP_FILE="dump_${TS}.dump"

echo "[1/4] Creating custom-format dump -> $DUMP_FILE"
pg_dump --format=custom --no-owner --no-acl -f "$DUMP_FILE" "$SRC_DATABASE_URL"
echo "Dump saved to: $DUMP_FILE"

echo "[2/4] Restoring dump into staging database"
# Use pg_restore --clean to remove objects before recreating. Assumes STAGING_DATABASE_URL points to the target DB.
pg_restore --no-owner --no-acl --clean --if-exists -d "$STAGING_DATABASE_URL" "$DUMP_FILE"
echo "Restore finished"

echo "[3/4] Run validation queries against staging to confirm (see scripts/staging_validation.sql)"
echo "Command example: psql \"$STAGING_DATABASE_URL\" -f backend/scripts/staging_validation.sql"

echo "[4/4] Done. Keep the dump file for auditing or delete when satisfied: rm -f $DUMP_FILE"

exit 0
