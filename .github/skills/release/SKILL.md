---
name: release
description: Create a new release — version bump, CHANGELOG update, git tag, and GitHub release.
---

# Release Skill

## When to use this

Use this skill when:
- **Releasing a new version** — after features are merged and ready for production
- **Creating git tags** — semantic versioning tags (v1.0.0, v1.1.0, etc.)
- **Publishing GitHub releases** — with release notes from CHANGELOG
- **Automating release process** — consistent, repeatable releases

DO NOT use for:
- Daily commits (use regular git workflow)
- Hotfixes that don't need a release

## How It Works

The release process:

1. Determine version type (major, minor, patch)
2. Collect commits since last tag
3. Categorize commits (feat → Added, fix → Fixed, refactor/chore/ci → Changed)
4. Auto-update CHANGELOG.md with categorized entries
5. Create git commit with version bump
6. Create git tag (v1.0.0)
7. Push to origin
8. Create GitHub release with release notes

## How to Run

### Agent Flow (Auto-Invoke)

When the user says "release", "create release", "new version", or "publish":

1. Agent reads this SKILL.md
2. Agent runs `release.sh auto` — script analyzes commits and determines version type
3. Agent reports result with version and type

No prompts needed — fully automatic detection.

### Auto-Detection Logic

**Version type detection:**

| Commit Pattern | Version | Example |
|---|---|---|
| Contains `BREAKING CHANGE` or `!:` | **Major** | `feat!: redesign API` |
| Starts with `feat:` | **Minor** | `feat: add user auth` |
| Everything else | **Patch** | `fix: handle null pointer` |

**CHANGELOG auto-update:**

| Commit Pattern | Category | Example Entry |
|---|---|---|
| `feat:` or `feat(scope):` | **Added** | `- add user auth (a1b2c3d)` |
| `fix:` or `fix(scope):` | **Fixed** | `- handle null pointer (e4f5g6h)` |
| `refactor:`, `chore:`, `ci:`, `docs:`, `style:`, `test:`, `perf:`, `build:` | **Changed** | `- update dependencies (i7j8k9l)` |
| Other conventional commits | **Other** | `- update README (m0n1o2p)` |

### Manual Run

```bash
.github/skills/release/scripts/release.sh [major|minor|patch]
```

### Examples

```bash
# Interactive — asks for version type
.github/skills/release/scripts/release.sh

# Direct — auto-determine next version
.github/skills/release/scripts/release.sh minor

# Dry run — show what would happen without executing
.github/skills/release/scripts/release.sh --dry-run
```

## Version Scheme

This project follows [Semantic Versioning](https://semver.org/):

| Version | When |
|---|---|
| **Major** (X.0.0) | Breaking API changes |
| **Minor** (0.X.0) | New features, backward compatible |
| **Patch** (0.0.X) | Bug fixes, backward compatible |

## CHANGELOG Format

```markdown
## [1.0.0] - 2026-07-25

### Added
- Feature A
- Feature B

### Fixed
- Bug fix X

### Changed
- Improvement Y
```

## GitHub Release

Each release includes:
- **Tag** — `v1.0.0`
- **Title** — `v1.0.0`
- **Release Notes** — Extracted from CHANGELOG.md
- **Assets** — Optional binary attachments
