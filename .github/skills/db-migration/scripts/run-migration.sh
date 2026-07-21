#!/usr/bin/env bash
# Apply a migration SQL file to every *.db file under db/ (tenants + global.db).
# Assumes SQLite. If this repo uses a different DB engine, adjust the `apply_one` function
# below (e.g. swap the `sqlite3` invocation for psql/mysql with per-tenant DSNs) and keep the
# rest of the script's flow (dry-run, stop-on-first-failure, verification) the same.
#
# Usage:
#   run-migration.sh <migration-file.sql>
#   run-migration.sh <migration-file.sql> --dry-run
#   run-migration.sh <migration-file.sql> --target <db-file-name>

set -euo pipefail

MIGRATION_FILE="${1:-}"
DRY_RUN=false
TARGET=""

shift || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --target) TARGET="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$MIGRATION_FILE" || ! -f "$MIGRATION_FILE" ]]; then
  echo "Usage: run-migration.sh <migration-file.sql> [--dry-run] [--target <db-file-name>]" >&2
  exit 1
fi

if [[ ! -d "db" ]]; then
  echo "Error: no db/ directory found here. Run this from the repo root." >&2
  exit 1
fi

if ! $DRY_RUN && ! command -v sqlite3 >/dev/null 2>&1; then
  echo "Error: sqlite3 CLI not found. Install it, or adapt this script for your DB engine." >&2
  exit 1
fi

if [[ -n "$TARGET" ]]; then
  DB_FILES=("db/${TARGET}")
  if [[ ! -f "${DB_FILES[0]}" ]]; then
    echo "Error: db/${TARGET} not found." >&2
    exit 1
  fi
else
  mapfile -t DB_FILES < <(find db -maxdepth 1 -name '*.db' | sort)
fi

if [[ ${#DB_FILES[@]} -eq 0 ]]; then
  echo "No .db files found under db/." >&2
  exit 1
fi

echo "Migration file : ${MIGRATION_FILE}"
echo "Target DB(s)   : ${#DB_FILES[@]}"
printf '  %s\n' "${DB_FILES[@]}"
echo "Dry run        : ${DRY_RUN}"
echo ""

for db in "${DB_FILES[@]}"; do
  if $DRY_RUN; then
    echo "[dry-run] would apply ${MIGRATION_FILE} to ${db}"
    continue
  fi

  echo "Applying to ${db} ..."
  if sqlite3 "${db}" < "${MIGRATION_FILE}"; then
    echo "  OK"
  else
    echo "  FAILED on ${db} — stopping so remaining DBs are not left further out of sync." >&2
    echo "  Databases already migrated before this failure may now differ from the rest." >&2
    exit 1
  fi
done

if ! $DRY_RUN; then
  echo ""
  echo "Done. Verify schema consistency across all DBs before considering this migration complete."
fi
