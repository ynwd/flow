#!/usr/bin/env bash
# webhook-to-task.sh — Terima payload dari issue tracker dan tulis ke task queue.
#
# Mode 1: Argumen langsung
#   .github/skills/webhook-to-task/scripts/webhook-to-task.sh \
#     --title "Blog page error 500" \
#     --priority P0 \
#     --source "manual"
#
# Mode 2: Pipe / stdin
#   cat /tmp/issue-payload.json | \
#     .github/skills/webhook-to-task/scripts/webhook-to-task.sh --stdin --format github
#
# Mode 3: File
#   .github/skills/webhook-to-task/scripts/webhook-to-task.sh \
#     --file /tmp/issue-payload.json --format github
#
# Supported formats:
#   --format github    GitHub Issues API payload
#   --format linear    Linear webhook payload
#   --format plain     Teks biasa (default untuk --stdin tanpa format)
#
# Must be run from the repo root.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
QUEUE_FILE="${REPO_ROOT}/.github/tasks/queue.md"

# ── Defaults ─────────────────────────────────────────────────
TITLE=""
PRIORITY="P1"
SOURCE="manual"
FORMAT="plain"
BODY=""
LABELS=""

# ── Parse args ───────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --title|-t)
      TITLE="$2"; shift 2 ;;
    --priority|-p)
      PRIORITY="$2"; shift 2 ;;
    --source|-s)
      SOURCE="$2"; shift 2 ;;
    --format|-f)
      FORMAT="$2"; shift 2 ;;
    --file)
      FILE="$2"; shift 2 ;;
    --stdin)
      STDIN=true; shift ;;
    --body|-b)
      BODY="$2"; shift 2 ;;
    --labels|-l)
      LABELS="$2"; shift 2 ;;
    --help|-h)
      echo "Usage: webhook-to-task.sh [options]"
      echo ""
      echo "Options:"
      echo "  --title, -t TEXT       Task title (required)"
      echo "  --priority, -p PRIO    P0, P1, P2 (default: P1)"
      echo "  --source, -s SOURCE    Source identifier (default: manual)"
      echo "  --format, -f FORMAT    Input format: github, linear, plain (default: plain)"
      echo "  --file FILE            Read payload from file"
      echo "  --stdin                Read payload from stdin"
      echo "  --body, -b TEXT        Description/body"
      echo "  --labels, -l TEXT      Comma-separated labels"
      echo "  --help, -h             Show this help"
      exit 0 ;;
    *)
      echo "Unknown option: $1"
      exit 1 ;;
  esac
done

# ── Parse input ──────────────────────────────────────────────
if [[ -n "${STDIN:-}" || -n "${FILE:-}" ]]; then
  if [[ -n "${FILE:-}" ]]; then
    INPUT=$(cat "$FILE")
  else
    INPUT=$(cat)
  fi

  case "$FORMAT" in
    github)
      TITLE=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('title',''))" 2>/dev/null || echo "")
      BODY=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('body',''))" 2>/dev/null || echo "")
      LABELS=$(echo "$INPUT" | python3 -c "
import sys,json
d=json.load(sys.stdin)
labels = [l.get('name','') for l in d.get('labels',[])]
print(','.join(labels))
" 2>/dev/null || echo "")
      # Map GitHub labels to priority
      if echo "$LABELS" | grep -qi "bug\|critical\|P0"; then PRIORITY="P0"; fi
      if echo "$LABELS" | grep -qi "enhancement\|feature\|P1"; then PRIORITY="P1"; fi
      if echo "$LABELS" | grep -qi "chore\|docs\|P2"; then PRIORITY="P2"; fi
      if [[ -z "$TITLE" ]]; then
        echo "❌ Could not parse title from GitHub payload"
        exit 1
      fi
      ;;
    linear)
      TITLE=$(echo "$INPUT" | python3 -c "
import sys,json
d=json.load(sys.stdin)
# Linear webhook: data.issue.title atau issue.title
issue = d.get('data',{}).get('issue', d)
print(issue.get('title',''))
" 2>/dev/null || echo "")
      PRIORITY_MAP=$(echo "$INPUT" | python3 -c "
import sys,json
d=json.load(sys.stdin)
issue = d.get('data',{}).get('issue', d)
prio = issue.get('priority', 0)
if prio <= 1: print('P0')
elif prio <= 2: print('P1')
else: print('P2')
" 2>/dev/null || echo "P1")
      PRIORITY="${PRIORITY_MAP:-P1}"
      if [[ -z "$TITLE" ]]; then
        echo "❌ Could not parse title from Linear payload"
        exit 1
      fi
      ;;
    plain)
      # Plain text: first line = title, rest = body
      if [[ -z "$TITLE" ]]; then
        TITLE=$(echo "$INPUT" | head -1)
        BODY=$(echo "$INPUT" | tail -n +2)
      fi
      ;;
  esac
fi

# ── Validate ─────────────────────────────────────────────────
if [[ -z "$TITLE" ]]; then
  echo "❌ Title is required. Use --title or pipe a payload."
  echo "   See --help for usage."
  exit 1
fi

if [[ ! "$PRIORITY" =~ ^P[012]$ ]]; then
  echo "❌ Invalid priority: $PRIORITY. Must be P0, P1, or P2."
  exit 1
fi

# ── Escape pipe chars for markdown table ─────────────────────
ESCAPED_TITLE=$(echo "$TITLE" | sed 's/|/\\|/g')
ESCAPED_BODY=$(echo "$BODY" | head -1 | sed 's/|/\\|/g')
DATE=$(date +%Y-%m-%d)

# ── Cek duplikat ─────────────────────────────────────────────
if grep -q "| $PRIORITY | $ESCAPED_TITLE |" "$QUEUE_FILE" 2>/dev/null; then
  echo "ℹ️  Task already exists in queue: [$PRIORITY] $TITLE"
  echo "   Skipping."
  exit 0
fi

# ── Insert task ke queue — urut berdasarkan prioritas ───────
# Cari baris "| — | — | — | — | — |" (separator setelah header tabel).
# Task baru diinsert sebagai baris baru SETELAH separator itu.
# Urutan prioritas di-maintain oleh cara insert (selalu di baris pertama
# setelah separator, sebelum task yang sudah ada dengan prioritas lebih rendah).
# Karena insert selalu di posisi yang tepat, urutan P0→P1→P2 terjaga.

# Hitung nomor baris separator
SEP_LINE=$(grep -n '^| — | — | — | — | — |$' "$QUEUE_FILE" | head -1 | cut -d: -f1)

if [[ -z "$SEP_LINE" ]]; then
  echo "❌ Could not find separator row in queue.md"
  exit 1
fi

# Cek apakah sudah ada task setelah separator. Kalau ada, cari baris pertama
# task dengan prioritas lebih rendah dari task baru — insert di situ.
INSERT_LINE=$((SEP_LINE + 1))
if [[ -n "$(sed -n "${INSERT_LINE}p" "$QUEUE_FILE")" ]]; then
  # Ada task existing — cari prioritas
  case "$PRIORITY" in
    P0) INSERT_LINE=$((SEP_LINE + 1)) ;;  # P0 always goes first
    P1)
      # Cek baris pertama: kalau P0, insert setelahnya
      FIRST_PRIO=$(sed -n "${INSERT_LINE}p" "$QUEUE_FILE" | awk '{print $2}')
      if [[ "$FIRST_PRIO" == "P0" ]]; then
        INSERT_LINE=$((INSERT_LINE + 1))
      fi
      ;;
    P2)
      # Cari baris terakhir task — insert setelahnya
      while sed -n "${INSERT_LINE}p" "$QUEUE_FILE" | grep -q '^| P[012] |'; do
        INSERT_LINE=$((INSERT_LINE + 1))
      done
      ;;
  esac
fi

# Insert baris baru di INSERT_LINE
TEMP=$(mktemp)
sed "${INSERT_LINE}i\\
| ${PRIORITY} | ${ESCAPED_TITLE} | ${SOURCE} | ${DATE} | pending |" "$QUEUE_FILE" > "$TEMP"
mv "$TEMP" "$QUEUE_FILE"

echo "✅ Task added to queue: [$PRIORITY] $TITLE"
echo "   File: .github/tasks/queue.md"
echo "   Source: $SOURCE"
if [[ -n "$ESCAPED_BODY" ]]; then
  echo "   Description: $ESCAPED_BODY"
fi
