#!/usr/bin/env bash
# squash-commits.sh — Squash semua commit di branch aktif jadi 1 commit.
#
# Menggabungkan seluruh riwayat commit di branch saat ini menjadi satu
# commit tunggal dengan pesan yang bisa ditentukan.
#
# Aman: tidak menyentuh branch lain. Hanya branch aktif yang di-reset.
#
# Usage:
#   .github/skills/squash-commits/scripts/squash-commits.sh <message>
#   .github/skills/squash-commits/scripts/squash-commits.sh "Initial commit"
#   .github/skills/squash-commits/scripts/squash-commits.sh "feat: add billing module"
#
# Options:
#   <message>   Pesan commit untuk commit hasil squash (wajib)
#
# Must be run from the repo root.

set -euo pipefail

# ── Parse args ──────────────────────────────────────────────────
PUSH_AFTER=false
MESSAGE=""

for arg in "$@"; do
  case "$arg" in
    --push) PUSH_AFTER=true ;;
    --no-push) PUSH_AFTER=false ;;
    --help|-h) echo "Usage: squash-commits.sh [--push|--no-push] <commit-message>"; exit 0 ;;
    -*) echo "Unknown option: $arg" >&2; exit 1 ;;
    *) MESSAGE="$arg" ;;
  esac
done

if [[ -z "$MESSAGE" ]]; then
  echo "Usage: squash-commits.sh [--push|--no-push] <commit-message>" >&2
  echo "  --push      Push to remote after squash (no prompt)" >&2
  echo "  --no-push   Skip push after squash (no prompt)" >&2
  echo "  Default     Shows prompt to ask user" >&2
  echo "" >&2
  echo "  Example: squash-commits.sh --push \"feat: add billing module\"" >&2
  exit 1
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "── Squashing commits on branch: ${BRANCH} ──"
echo ""

# Cek jumlah commit
COMMIT_COUNT=$(git rev-list --count HEAD)
echo "  Current commits: ${COMMIT_COUNT}"

if [[ "$COMMIT_COUNT" -le 1 ]]; then
  echo "  ⏭  Hanya ada 1 commit — tidak perlu squash."
  echo ""
  UNPUSHED=$(git log origin/"$BRANCH"..HEAD 2>/dev/null | wc -l)
  if [[ "$UNPUSHED" -gt 0 ]]; then
    if [[ "$PUSH_AFTER" == "true" ]]; then
      git push --force-with-lease origin "$BRANCH"
      echo "  ✓ Pushed to origin/$BRANCH"
    elif [[ "$PUSH_AFTER" == "false" ]] && [[ $# -eq 0 || "$*" == *"--no-push"* ]]; then
      echo "  Lewati push."
    else
      echo "  NEEDS_PUSH=true"
    fi
  fi
  exit 0
fi

# Cari root commit (commit pertama tanpa parent)
ROOT_SHA=$(git rev-list --max-parents=0 HEAD)
echo "  Root commit: $(echo "$ROOT_SHA" | head -c 12)"

# Soft reset ke root commit — staging semua perubahan
git reset --soft "$ROOT_SHA"
echo "  ✓ Soft reset ke root commit"

# Amend root commit dengan semua perubahan (bukan commit baru)
git commit --amend -m "$MESSAGE"
echo "  ✓ Squash selesai — semua ${COMMIT_COUNT} commit → 1 commit"

echo ""
# Push handling — agent prompts user via vscode_askQuestions before calling script
if [[ "$PUSH_AFTER" == "true" ]]; then
  git push --force-with-lease origin "$BRANCH"
  echo "  ✓ Pushed to origin/$BRANCH"
elif [[ "$PUSH_AFTER" == "false" ]] && [[ $# -eq 0 || "$*" == *"--no-push"* ]]; then
  echo "  Lewati push."
else
  echo "  NEEDS_PUSH=true"
fi

echo ""
echo "── Done ──"
echo "  Branch: ${BRANCH}"
echo "  Message: ${MESSAGE}"
