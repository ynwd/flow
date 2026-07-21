#!/usr/bin/env bash
# init-core.sh — Initialize core project from templates.
#
# Creates all core files (root/, core/, cmd/, modules/) from templates
# in .github/skills/init-core-project/templates/.
#
# Safe to run anytime:
# - Files that ALREADY EXIST (tracked in .core-state.json) will not be overwritten.
# - Files that DO NOT EXIST will be created from templates.
#
# State disimpan di .core-state.json (root project).
# Untuk memaksa recreate semua file: hapus state file atau set created=false.
#
# Usage:
#   .github/skills/init-core-project/scripts/init-core.sh
#
# Must be run from the repo root.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${SKILL_DIR}/../../../" && pwd)"
TEMPLATES_DIR="${SKILL_DIR}/templates"
STATE_FILE="${REPO_ROOT}/.core-state.json"

if [[ ! -d "$TEMPLATES_DIR" ]]; then
  echo "Error: templates/ not found at ${TEMPLATES_DIR}" >&2
  exit 1
fi

# Parse flags
FORCE=false
SKIP_POST=false
for arg in "$@"; do
  case $arg in
    --force) FORCE=true ;;
    --skip-post) SKIP_POST=true ;;
  esac
done

if [[ ! -f "$STATE_FILE" ]]; then
  if $FORCE; then
    # Generate .core-state.json dari template files
    echo "  → Creating .core-state.json from templates..."
    python3 -c "
import json, os, re

templates_dir = '$TEMPLATES_DIR'
state = {'version': 1, 'files': {}}
for root, dirs, files in os.walk(templates_dir):
    for f in files:
        if f.endswith('.tmpl'):
            rel = os.path.relpath(os.path.join(root, f), templates_dir)
            rel = re.sub(r'\.tmpl$', '', rel)
            state['files'][rel] = {'created': False, 'hash': ''}
with open('$STATE_FILE', 'w') as fh:
    json.dump(state, fh, indent=2)
    fh.write('\n')
  " 2>/dev/null || python -c "
import json, os, re

templates_dir = '$TEMPLATES_DIR'
state = {'version': 1, 'files': {}}
for root, dirs, files in os.walk(templates_dir):
    for f in files:
        if f.endswith('.tmpl'):
            rel = os.path.relpath(os.path.join(root, f), templates_dir)
            rel = re.sub(r'\.tmpl$', '', rel)
            state['files'][rel] = {'created': False, 'hash': ''}
with open('$STATE_FILE', 'w') as fh:
    json.dump(state, fh, indent=2)
    fh.write('\n')
  "
    echo "  ✓ .core-state.json created (${TEMPLATES_DIR})"
  else
    echo "⚠️  .core-state.json not found at ${STATE_FILE}" >&2
    echo "  If this is a fresh clone, run with --force to create new state." >&2
    echo "  If files already exist but state is missing — existing files will NOT be overwritten." >&2
    echo "" >&2
    echo "  Usage: $0 [--force]" >&2
    echo "    --force   Create new .core-state.json and recreate all core files" >&2
    exit 1
  fi
elif $FORCE; then
  # --force: reset semua state ke created:false agar ditimpa
  echo "  → Force mode: reset .core-state.json..."
  jq '.files |= with_entries(.value.created = false | .value.hash = "")' "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
  CREATED_COUNT=$(jq '.files | length' "$STATE_FILE")
  echo "  ✓ .core-state.json reset (${CREATED_COUNT} files → created: false)"
fi

CREATED=0
SKIPPED=0

echo "── Initializing core project ──"
echo ""

# Walk all .tmpl files in templates/ — use process substitution to avoid subshell
while IFS= read -r -d '' tmpl; do
  # Compute relative path: strip TEMPLATES_DIR/ prefix and .tmpl suffix
  rel="${tmpl#$TEMPLATES_DIR/}"
  rel="${rel%.tmpl}"

  target="${REPO_ROOT}/${rel}"

  # Check state
  if jq -e --arg f "$rel" '.files[$f].created == true' "$STATE_FILE" > /dev/null 2>&1; then
    echo "  ⏭  ${rel} (already exists)"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  # Safety: if file exists on disk but state not recorded, don't overwrite
  if [[ -f "$target" ]] && ! $FORCE; then
    echo "  ⏭  ${rel} (exists on disk, use --force to overwrite)"
    SKIPPED=$((SKIPPED + 1))
    # Update state agar tidak ditanya lagi
    jq --arg f "$rel" '.files[$f].created = true' "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
    continue
  fi

  # Create parent directory if needed
  mkdir -p "$(dirname "$target")"

  # Copy template to target
  cp "$tmpl" "$target"
  echo "  ✓  ${rel}"

  # Update state
  jq --arg f "$rel" '.files[$f].created = true' "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"

  CREATED=$((CREATED + 1))
done < <(find "$TEMPLATES_DIR" -name '*.tmpl' -print0)

echo ""

# ── Post-init tasks ──────────────────────────────────────────────
if [[ "$CREATED" -gt 0 ]] && [[ "$SKIP_POST" == false ]]; then
  echo "── Post-init ──"

  cd "$REPO_ROOT"

  # go.sum mungkin hilang karena go.mod baru di-create
  if [[ ! -f "go.sum" ]]; then
    echo "  → go mod tidy..."
    go mod tidy 2>&1 | sed 's/^/    /'
    echo "  ✓ go.mod / go.sum updated"
  fi

  # Register index module in modules/register.go
  REG="modules/register.go"
  IMPORT="_ \"github.com/ynwd/flow/modules/index\""
  if [[ -f "$REG" ]] && ! grep -q "$IMPORT" "$REG" 2>/dev/null; then
    if grep -q "import (" "$REG"; then
      sed -i "/^)/i\\\t$IMPORT" "$REG"
    else
      echo -e "package modules\n\nimport (\n\t$IMPORT\n)" > "$REG"
    fi
    echo "  ✓ Registered index module"
  fi

  # node_modules may not exist yet — run npm install
  if [[ ! -d "node_modules" ]]; then
    echo "  → npm install..."
    npm install --silent 2>&1 | tail -1 | sed 's/^/    /'
    echo "  ✓ node_modules installed"
  fi

  # Build Tailwind CSS (app.min.css)
  echo "  → npm run build:css..."
  npm run build:css 2>&1 | tail -1 | sed 's/^/    /'
  echo "  ✓ Tailwind CSS built"

  # Build Go binary — verify compilation
  echo "  → go build ./..."
  go build ./... 2>&1 | sed 's/^/    /'
  echo "  ✓ Go build OK"
fi

echo ""
echo "── Done ──"
echo "  Created: ${CREATED}  Skipped: ${SKIPPED}"
