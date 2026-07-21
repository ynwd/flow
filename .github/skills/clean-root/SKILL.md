---
name: clean-root
description: Clean all files from init-core and scaffold — restore repo to fresh-clone state, keeping only .git/, .github/, .gitignore, README.md, and .vscode/. Run AFTER experimentation or before starting over from scratch.
---

# Clean Root Skill

## When to use this

Use this skill when:
- **Reset experiment** — want to delete all files created by `init-core-project`
  and `new-feature-module`, restoring the repo to fresh clone state.
- **Before re-demo** — want to demonstrate the flow from scratch (clone → init → scaffold).
- **Error recovery** — project is in a dirty state and want to start fresh without re-cloning.

DO NOT use for:
- Removing a specific module (just `rm -rf modules/<name>` + manual cleanup)
- Removing only 1-2 files

## How It Works

The `clean-root.sh` script will:

1. Reset `.core-state.json` — all `created` set to `false`, all `hash` cleared.
2. Delete all files recorded in `.core-state.json` (24 files: `main.go`, `go.mod`,
   entire `core/`, `cmd/`, `modules/register.go`, `package.json`, config files, etc.)
3. Delete the `modules/` folder (all scaffolded modules).
4. Delete the `components/` folder (shared components like Card).
5. Delete `go.sum` (will regenerate when `init-core.sh` runs).
6. Delete `node_modules/` and `package-lock.json`.
7. Leave only pure repo files: `.git/`, `.github/`, `.gitignore`, `README.md`, `.vscode/`,
   `.core-state.json`, `devto-article.md`.
8. **Reset `.github/tasks/`** — archive checkpoints, clear queue, clean done/blocked.

## How to Run

```bash
.github/skills/clean-root/scripts/clean-root.sh
```

Run from the repo root. No confirmation needed — the script is idempotent and safe.

## Output

```
── Cleaning root ──
  ✓ Reset .core-state.json (24 files → created: false)
  ✓ Removed main.go
  ✓ Removed go.mod
  ✓ Removed go.sum
  ✓ Removed package.json
  ✓ Removed postcss.config.js
  ✓ Removed vitest.config.ts
  ✓ Removed vitest.setup.ts
  ✓ Removed core/
  ✓ Removed cmd/
  ✓ Removed modules/
  ✓ Removed components/
  ✓ Removed node_modules/
  ✓ Removed package-lock.json
  ✓ Reset .github/tasks/ (queue, session, done, blocked)

── Done ──
  Repository is clean. Run init-core.sh to start fresh.
```

## Integration

This skill is a **partner** to `init-core-project`:

```
clean-root → init-core → scaffold → implement
```

The correct order after clone or reset:
1. `clean-root` (if cleanup is needed)
2. `init-core-project` — create all core files from template
3. `new-feature-module` — scaffold a new module
