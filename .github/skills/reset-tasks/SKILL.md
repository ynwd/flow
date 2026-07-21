---
name: reset-tasks
description: Reset task queue and clean all checkpoint/session state in .github/tasks/. Does not delete any code.
---

# Reset Tasks Skill

## When to use this

Use this skill when:
- **All tasks are done** — queue needs to be cleared for a new session.
- **Checkpoint is corrupted** — `current.md` content is out of sync with reality.
- **Want to restart planning** — want to start tasks from scratch without deleting existing code.

DO NOT use for:
- Deleting modules or code (use `clean-root`).
- Removing just one task from the queue (just edit `queue.md` manually).

## How It Works

The `reset-tasks.sh` script will:

1. **Archive checkpoint** — if `session/current.md` contains data (not a placeholder), move it to `session/archive/` with a timestamp.
2. **Reset `current.md`** — restore to empty placeholder.
3. **Clear `queue.md`** — remove all tasks, keep empty table structure.
4. **Clean `done/` and `blocked/`** — remove all `.md` files except `README.md`.

## How to Run

```bash
.github/skills/reset-tasks/scripts/reset-tasks.sh
```

Run from the repo root. Idempotent and safe — does not touch code.

## Output

```
── Resetting task queue ──

  ✓ Archived current.md → session/archive/checkpoint-20260718-103000.md
  ✓ Reset session/current.md to placeholder
  ✓ Reset queue.md to empty
  ✓ Cleared done/ (kept README.md)
  ✓ Cleared blocked/ (kept README.md)

── Done ──
  Task queue reset successfully.
  Previous checkpoint archived (if any).
  Add new tasks to .github/tasks/queue.md
```

## Integration

Can be called at any time, independent of other skills. Not related to `init-core` or `clean-root`.
