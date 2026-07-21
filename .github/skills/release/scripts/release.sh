#!/usr/bin/env bash
# release.sh — Create a new release with version bump, CHANGELOG update, and GitHub release.
#
# Usage:
#   release.sh [major|minor|patch|auto] [--dry-run]
#
# Auto mode: analyzes commits since last tag to determine version type.
# - Contains "BREAKING CHANGE" or "!" → major
# - Starts with "feat:" → minor
# - Everything else → patch
#
# Must be run from the repo root.

set -euo pipefail

DRY_RUN=false
VERSION_TYPE="${1:-}"

# Parse flags
for arg in "$@"; do
  case $arg in
    --dry-run)
      DRY_RUN=true
      ;;
    major|minor|patch|auto)
      VERSION_TYPE="$arg"
      ;;
  esac
done

# ── Helpers ──────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}✓${NC} $1"; }
warn()  { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1" >&2; exit 1; }

# ── Auto-detect version type from commits ────────────────

detect_version_type() {
  local latest_tag
  latest_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
  
  # Get commits since last tag (or all commits if no tag)
  local commits
  if [[ -n "$latest_tag" ]]; then
    commits=$(git log "${latest_tag}..HEAD" --pretty=format:"%s" 2>/dev/null || echo "")
  else
    commits=$(git log --pretty=format:"%s" 2>/dev/null || echo "")
  fi
  
  # Check for breaking changes
  if echo "$commits" | grep -qiE "(BREAKING CHANGE|breaking:|^[a-z]+!:|^[a-z]+\(.+\)!:)" ; then
    echo "major"
    return
  fi
  
  # Check for new features
  if echo "$commits" | grep -qiE "^feat(\(|:)" ; then
    echo "minor"
    return
  fi
  
  # Default to patch
  echo "patch"
}

# ── Pre-flight checks ───────────────────────────────────

# Ensure clean working tree
if [[ -n "$(git status --porcelain)" ]]; then
  error "Working tree is not clean. Commit or stash changes first."
fi

# Ensure we're on main
BRANCH=$(git branch --show-current)
if [[ "$BRANCH" != "main" ]]; then
  warn "Not on main branch (current: $BRANCH)"
  read -p "Continue anyway? [y/N] " -n 1 -r
  echo
  [[ $REPLY =~ ^[Yy]$ ]] || exit 1
fi

# ── Determine version type ───────────────────────────────

if [[ -z "$VERSION_TYPE" ]]; then
  echo "Select version type:"
  echo "  1) Auto-detect from commits"
  echo "  2) Major (breaking changes)"
  echo "  3) Minor (new features)"
  echo "  4) Patch (bug fixes)"
  read -p "Choice [1-4]: " choice
  case $choice in
    1) VERSION_TYPE="auto" ;;
    2) VERSION_TYPE="major" ;;
    3) VERSION_TYPE="minor" ;;
    4) VERSION_TYPE="patch" ;;
    *) error "Invalid choice" ;;
  esac
fi

# Auto-detect if requested
if [[ "$VERSION_TYPE" == "auto" ]]; then
  VERSION_TYPE=$(detect_version_type)
  info "Auto-detected version type: ${VERSION_TYPE}"
fi

# ── Calculate next version ───────────────────────────────

# Get latest tag, default to v0.0.0
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
CURRENT_VERSION="${LATEST_TAG#v}"

IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

case $VERSION_TYPE in
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  patch)
    PATCH=$((PATCH + 1))
    ;;
  *)
    error "Invalid version type: $VERSION_TYPE (use major, minor, or patch)"
    ;;
esac

NEXT_VERSION="v${MAJOR}.${MINOR}.${PATCH}"
TODAY=$(date +%Y-%m-%d)

echo ""
echo "── Release Plan ──"
echo ""
echo "  Current:  ${LATEST_TAG:-none}"
echo "  Next:     ${NEXT_VERSION}"
echo "  Type:     ${VERSION_TYPE}"
echo "  Date:     ${TODAY}"
echo "  Branch:   ${BRANCH}"
echo ""

# ── Dry run ──────────────────────────────────────────────

if [[ "$DRY_RUN" == true ]]; then
  warn "DRY RUN — no changes will be made"
  echo ""
  echo "Would do:"
  echo "  1. Update CHANGELOG.md: ## [${NEXT_VERSION}] - ${TODAY}"
  echo "  2. Git commit: 'release: ${NEXT_VERSION}'"
  echo "  3. Git tag: ${NEXT_VERSION}"
  echo "  4. Git push origin main ${NEXT_VERSION}"
  echo "  5. GitHub release with CHANGELOG notes"
  echo ""
  exit 0
fi

# ── Confirm ──────────────────────────────────────────────

read -p "Create release ${NEXT_VERSION}? [y/N] " -n 1 -r
echo
[[ $REPLY =~ ^[Yy]$ ]] || exit 1

# ── Update CHANGELOG.md ──────────────────────────────────

if [[ ! -f CHANGELOG.md ]]; then
  error "CHANGELOG.md not found"
fi

# Collect commits since last tag
if [[ -n "$LATEST_TAG" ]]; then
  COMMITS=$(git log "${LATEST_TAG}..HEAD" --pretty=format:"%s|%h" 2>/dev/null)
else
  COMMITS=$(git log --pretty=format:"%s|%h" 2>/dev/null)
fi

# Build new changelog entries
NEW_ENTRIES=""
while IFS='|' read -r MSG HASH; do
  [[ -z "$MSG" ]] && continue
  
  # Skip release commits
  [[ "$MSG" =~ ^release: ]] && continue
  
  # Categorize
  if [[ "$MSG" =~ ^feat(\(.+\))?: ]]; then
    DESC=$(echo "$MSG" | sed -E 's/^feat(\([^)]*\))?:\s*//')
    NEW_ENTRIES="${NEW_ENTRIES}- ${DESC} ([${HASH}](https://github.com/ynwd/flow/commit/${HASH}))\n"
  elif [[ "$MSG" =~ ^fix(\(.+\))?: ]]; then
    DESC=$(echo "$MSG" | sed -E 's/^fix(\([^)]*\))?:\s*//')
    NEW_ENTRIES="${NEW_ENTRIES}- ${DESC} ([${HASH}](https://github.com/ynwd/flow/commit/${HASH}))\n"
  elif [[ "$MSG" =~ ^(refactor|chore|ci|docs|style|test|perf|build)(\(.+\))?: ]]; then
    DESC=$(echo "$MSG" | sed -E 's/^[a-z]+(\([^)]*\))?:\s*//')
    NEW_ENTRIES="${NEW_ENTRIES}- ${DESC} ([${HASH}](https://github.com/ynwd/flow/commit/${HASH}))\n"
  fi
done <<< "$COMMITS"

# Create temp file with new changelog
TEMP_FILE=$(mktemp)
cat > "$TEMP_FILE" << EOF
# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

- Nothing yet.

## [${NEXT_VERSION}] - ${TODAY}

$(echo -e "$NEW_ENTRIES")
EOF

# Append existing changelog after first version header
awk '/^## \[0\./{found=1} found{print}' CHANGELOG.md >> "$TEMP_FILE"

# Replace CHANGELOG.md
mv "$TEMP_FILE" CHANGELOG.md
info "Updated CHANGELOG.md"

# ── Git commit + tag ─────────────────────────────────────

git add CHANGELOG.md
git commit -m "release: ${NEXT_VERSION}"
info "Committed version bump"

git tag -a "$NEXT_VERSION" -m "Release ${NEXT_VERSION}"
info "Created tag ${NEXT_VERSION}"

# ── Push ─────────────────────────────────────────────────

git push origin "$BRANCH" "$NEXT_VERSION"
info "Pushed to origin"

# ── GitHub Release ───────────────────────────────────────

# Extract release notes from CHANGELOG.md (content between version header and next header)
NOTES=$(awk "/^## \[${NEXT_VERSION}\]/{found=1; next} /^## \[/{if(found) exit} found{print}" CHANGELOG.md)

if command -v gh &> /dev/null; then
  echo "$NOTES" | gh release create "$NEXT_VERSION" \
    --title "$NEXT_VERSION" \
    --notes-file - \
    --verify-tag
  info "Created GitHub release: ${NEXT_VERSION}"
else
  warn "gh CLI not found — create release manually at:"
  warn "https://github.com/$(git remote get-url origin | sed 's|.*github.com[:/]||; s|\.git$||')/releases/new?tag=${NEXT_VERSION}"
fi

# ── Done ─────────────────────────────────────────────────

echo ""
echo "── Release Complete ──"
echo ""
echo "  Version:  ${NEXT_VERSION}"
echo "  Tag:      ${NEXT_VERSION}"
echo "  Branch:   ${BRANCH}"
echo ""
