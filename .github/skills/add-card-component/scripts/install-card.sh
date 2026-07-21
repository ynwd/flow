#!/usr/bin/env bash
# install-card.sh — Copy Card component templates to components/Card/
# Usage: .github/skills/add-card-component/scripts/install-card.sh [--force]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATES_DIR="$SKILL_DIR/templates"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
TARGET_DIR="$REPO_ROOT/components/Card"

FORCE=false
if [[ "${1:-}" == "--force" ]]; then
  FORCE=true
fi

# Check if already installed
if [[ -d "$TARGET_DIR" ]] && [[ "$FORCE" != "true" ]]; then
  echo "✓ Card component already exists at components/Card/"
  echo "  Use --force to overwrite"
  exit 0
fi

echo "── Installing Card component ──"

# Create target directory
mkdir -p "$TARGET_DIR"

# Copy templates (remove .tmpl extension)
for tmpl in "$TEMPLATES_DIR"/components/Card/*.tmpl; do
  filename="$(basename "$tmpl" .tmpl)"
  if [[ -f "$TARGET_DIR/$filename" ]] && [[ "$FORCE" != "true" ]]; then
    echo "  ⊘ $filename (exists, skipped)"
  else
    cp "$tmpl" "$TARGET_DIR/$filename"
    echo "  ✓ $filename"
  fi
done

echo ""
echo "── Done ──"
echo "Card component installed at: components/Card/"
echo ""
echo "Usage example:"
echo '  import { Card } from "../components/Card";'
echo ""
echo '  <Card variant="modal">'
echo '    <Card.Header title="Title" progress={{ current: 1, total: 3 }} />'
echo '    <Card.Content>...</Card.Content>'
echo '    <Card.Footer stepIndicator={{ current: 1, total: 3 }} />'
echo '  </Card>'
