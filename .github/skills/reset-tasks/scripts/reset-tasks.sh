#!/usr/bin/env bash
# reset-tasks.sh — Reset task queue and clear all checkpoint/session state.
#
# Useful when:
# - All tasks are done and you want a clean queue
# - You want to start task planning from scratch
# - Checkpoint is corrupt / out of sync
#
# Does NOT delete code, core, or module files.
# Only touches .github/tasks/.
#
# Usage:
#   .github/skills/reset-tasks/scripts/reset-tasks.sh [--quiet]
#
# Must be run from the repo root.
#
# Options:
#   --quiet   Suppress output (used by clean-root.sh via delegation)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
TASKS_DIR="${REPO_ROOT}/.github/tasks"
QUIET=false

for arg in "$@"; do
  case "$arg" in
    --quiet) QUIET=true ;;
  esac
done

if ! $QUIET; then
  echo "── Resetting task queue ──"
  echo ""
fi

# ── 1. Archive current.md ke archive/ kalau ada isinya ──────
CURRENT="${TASKS_DIR}/session/current.md"
if [[ -f "$CURRENT" ]]; then
  CONTENT_LINES=$(grep -c -v "^\-\-\-" "$CURRENT" 2>/dev/null || true)
  if [[ "$CONTENT_LINES" -gt 5 ]]; then
    mkdir -p "${TASKS_DIR}/session/archive"
    ARCHIVE_NAME="checkpoint-$(date +%Y%m%d-%H%M%S).md"
    cp "$CURRENT" "${TASKS_DIR}/session/archive/${ARCHIVE_NAME}"
    $QUIET || echo "  ✓ Archived current.md → session/archive/${ARCHIVE_NAME}"
  fi
fi

# ── 2. Reset current.md ke placeholder ──────────────────────
cat > "$CURRENT" << 'EOF'
# Session Checkpoint

_No active tasks. Checkpoint will be created automatically by the agent when a P0/P1 task starts._

---
EOF
$QUIET || echo "  ✓ Reset session/current.md to placeholder"

# ── 3. Kosongkan queue.md ────────────────────────────────────
cat > "${TASKS_DIR}/queue.md" << 'QEOF'
# Task Queue

Format: `[PRIO] task | requested_by | date | status`

| Prio | Task | Requested | Date | Status |
|---|---|---|---|---|
| — | — | — | — | — |

## Priority Levels

- **P0** — Critical: bug, broken build, production issue. Must be handled immediately.
- **P1** — Feature: new module, new endpoint, enhancement. Default for feature requests.
- **P2** — Chore: refactor, dependency update, tech debt, minor improvement.

## Rules

1. Orchestrator works on the highest priority task with status `pending`.
2. Only one task can be `in_progress` at a time — do not start a new task before the current one is done or blocked.
3. When a task is done → move the row to `.github/tasks/done/<date>-<task>.md`.
4. When a task fails 3x → move to `.github/tasks/blocked/<task>.md` + log reason.
5. Active checkpoint is at `.github/tasks/session/current.md`.
QEOF
$QUIET || echo "  ✓ Reset queue.md to empty"

# ── 4. Kosongkan done/ dan blocked/ ──────────────────────────
for dir in done blocked; do
  for f in "${TASKS_DIR}/${dir}"/*.md; do
    bn=$(basename "$f")
    [[ -f "$f" && "$bn" != "README.md" && "$bn" != "TEMPLATE.md" ]] && rm -f "$f"
  done
  $QUIET || echo "  ✓ Cleared ${dir}/ (kept README.md, TEMPLATE.md)"
done

if ! $QUIET; then
  echo ""
  echo "── Done ──"
  echo "  Task queue reset successfully."
  echo "  Previous checkpoint archived (if any)."
  echo "  Add new tasks to .github/tasks/queue.md"
fi
