#!/usr/bin/env bash
# generate-migration.sh — Generate timestamped SQL migration file.
#
# Membuat file migration SQL dengan timestamp dan nama deskriptif
# di direktori yang bisa dipilih (default: db/migrations/).
#
# Usage:
#   .github/skills/db-migration/scripts/generate-migration.sh <description>
#   .github/skills/db-migration/scripts/generate-migration.sh add_users_table
#   .github/skills/db-migration/scripts/generate-migration.sh "add users table"
#
# Must be run from the repo root.

set -euo pipefail

DESCRIPTION="${1:-}"
if [[ -z "$DESCRIPTION" ]]; then
  echo "Usage: generate-migration.sh <description>" >&2
  echo "  Example: generate-migration.sh add_users_table" >&2
  echo "  Example: generate-migration.sh \"add users table\"" >&2
  exit 1
fi

# Sanitize: lowercase, replace spaces/special chars with underscores
SANITIZED=$(echo "$DESCRIPTION" \
  | tr '[:upper:]' '[:lower:]' \
  | sed 's/[^a-z0-9_]/_/g' \
  | sed 's/__*/_/g' \
  | sed 's/^_//;s/_$//')

TIMESTAMP=$(date +%Y%m%d%H%M%S)
FILENAME="${TIMESTAMP}_${SANITIZED}.sql"

# Default migrasi directory; bisa di-override via env
MIGRATIONS_DIR="${MIGRATIONS_DIR:-db/migrations}"
mkdir -p "$MIGRATIONS_DIR"

MIGRATION_PATH="${MIGRATIONS_DIR}/${FILENAME}"

if [[ -f "$MIGRATION_PATH" ]]; then
  echo "Error: Migration file already exists: ${MIGRATION_PATH}" >&2
  exit 1
fi

cat > "$MIGRATION_PATH" << SQL
-- Migration: ${SANITIZED}
-- Created at: $(date -u '+%Y-%m-%d %H:%M:%S UTC')
-- Description: ${DESCRIPTION}
--
-- Write your SQL below (SQLite-compatible syntax):
-- Separate 'up' and 'down' migrations with comment lines.

-- === UP ===
-- Example:
-- CREATE TABLE IF NOT EXISTS users (
--     id TEXT PRIMARY KEY,
--     name TEXT NOT NULL,
--     created_at TEXT DEFAULT (datetime('now'))
-- );

-- === DOWN ===
-- Example:
-- DROP TABLE IF EXISTS users;
SQL

echo "  ✓ Created migration: ${MIGRATION_PATH}"
echo ""
echo "Next step: apply with run-migration.sh"
echo "  .github/skills/db-migration/scripts/run-migration.sh ${MIGRATION_PATH}"
