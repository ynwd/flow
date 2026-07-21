---
name: init-core-project
description: Initialize core project from template — creates all root files, core/, cmd/, modules/register.go, and index landing page (React + SSR) from provided templates. Includes state tracking to avoid overwriting existing files. Run this AFTER clone repo or reset, BEFORE creating new modules.
---

# Init Core Project Skill

## When to use this

Use this skill when:
- **Clone new repo** — first time after `git clone`, to create the core structure
- **Reset project** — want to recreate core files from template (e.g. after experimentation)
- **Before scaffolding module** — scaffold will check state and ask for init-core first if core has not been initialized

DO NOT use for:
- Scaffolding feature modules (use `new-feature-module` skill)
- Editing existing core files (state will skip files that are already recorded)

## What it creates

- Core platform: `core/`, `cmd/`, `main.go`, `go.mod`
- Index landing page: `modules/index/` with React component (`Landing.tsx`), SSR shell + skeleton, esbuild config
- Root config: `package.json` (workspaces), `postcss.config.js`, `vitest.config.ts`
- State tracking: `.core-state.json`

## How It Works

All core project files (`main.go`, `go.mod`, `core/`, `cmd/migrate/main.go`, `modules/register.go`, etc.)
are stored as templates in:

```
.github/skills/init-core-project/templates/
```

State tracking is stored in:

```
.core-state.json (root project)
```

Format state:

```json
{
  "version": 1,
  "files": {
    "main.go": { "created": true, "hash": "c650abdfea7d4701" },
    "core/router/router.go": { "created": true, "hash": "6a7db0c91cc68360" },
    ...
  }
}
```

- `created: true` = file has been created before, will NOT be overwritten
- `created: false` = file will be created when init-core runs
- `hash` = SHA256[:16] of file content when first created (for reference)

## How to Run

```bash
.github/skills/init-core-project/scripts/init-core.sh
```

Run from the repo root. The script will:
1. Read `.core-state.json`
2. Loop all `.tmpl` files in `templates/`
3. Skip files with `created: true`
4. Copy files with `created: false` to their target locations
5. Update state to `created: true`
6. **Post-init**: run `go mod tidy` (generate `go.sum`) and `npm install` (install `node_modules`) if there are new files

## Adding New Core Files

If there are new core files that need to be added to the template:

1. Create a `.tmpl` file in `templates/` with the same path as the target location
2. Add an entry to `.core-state.json` with `"created": false`
3. Run `init-core.sh` to create the file

Or if the file was already created manually, update the state:

```bash
jq '.files["path/to/file.go"].created = true' .core-state.json > tmp.json && mv tmp.json .core-state.json
```

## Integration with scaffold.sh

The `scaffold.sh` in the `new-feature-module` skill automatically checks whether core has been initialized.
If any core file has `created: false`, scaffold will refuse and ask to run `init-core.sh` first.

## Sync Templates

After editing core files (`core/router/router.go`, `core/templates/landing.html`, etc.),
run the sync script to update the `.tmpl` templates:

```bash
.github/skills/init-core-project/scripts/sync-templates.sh
```

This script will:
1. Copy all core files to `templates/` with `.tmpl` suffix
2. Update hash in `.core-state.json`
