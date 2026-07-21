---
agent: 'ask'
description: 'Write a checkpoint snapshot of the current task progress to .github/tasks/session/current.md and commit it'
---

Write a checkpoint to `.github/tasks/session/current.md` using the format below.

## When to use

Use this skill when:
- Task has run >10 agent steps and is still in progress (P0/P1 only — small tasks <10 steps don't need checkpoints).
- Before restarting a session (e.g. context is full, or user asks to continue tomorrow).
- When there is an important design decision that needs to be recorded.

DO NOT use for:
- Small tasks that finish in 1-2 steps.
- Tasks that are already complete (write directly to done/ instead).

## Checkpoint format

```markdown
# Session Checkpoint — YYYY-MM-DD HH:MM

## Task: <priority> — <task-name>

### Status
- [x] <completed item>
- [ ] <pending item>

### Files changed (since last checkpoint)
- `<path/file.go>` — <one-line summary of change>

### Decision log
- <decision> → <reason>

### Blocker (if any)
- <what is blocking, or "none">

### Next steps
1. <step 1>
2. <step 2>
3. <step 3>
```

## After writing

Run the following commands to commit the checkpoint:

```bash
git add .github/tasks/session/current.md
git commit -m "chore: checkpoint <task-name> — <5-10 word progress summary>"
```
