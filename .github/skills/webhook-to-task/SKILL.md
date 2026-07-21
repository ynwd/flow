---
name: webhook-to-task
description: Receive payload from issue tracker (GitHub Issues, Linear, or plain text) and write to task queue (.github/tasks/queue.md). Does not edit any code.
---

# Webhook to Task Skill

## When to use this

Use this skill when:
- **User provides a task list** — can be piped to the script instead of manually writing to `queue.md`.
- **Input from issue tracker** — script can parse JSON from GitHub Issues, Linear, or other formats via file/stdin.
- **Integration with local webhook** — script can be called from a local webhook server (e.g. via `nc` or `socat`).

DO NOT use for:
- Adding tasks manually (just edit `queue.md` directly).
- Resetting task queue (use `reset-tasks` skill).

## How It Works

The `webhook-to-task.sh` script receives input and writes tasks to `.github/tasks/queue.md`.

The script automatically:
1. Parses input according to format (GitHub, Linear, plain).
2. Validates title and priority.
3. Checks for duplicates — skips if task already exists in queue.
4. Inserts task into the queue.md table with status `pending`.

## How to Run

### Mode 1: Direct arguments

```bash
.github/skills/webhook-to-task/scripts/webhook-to-task.sh \
  --title "Blog page error 500" \
  --priority P0 \
  --source "manual" \
  --body "Blog page error 500 on GET /blog"
```

### Mode 2: Pipe JSON from file

```bash
cat /tmp/issue.json | \
  .github/skills/webhook-to-task/scripts/webhook-to-task.sh --stdin --format github
```

### Mode 3: Plain text pipe

```bash
echo -e "Fix login broken\nToken expiry not handled, users get 401" | \
  .github/skills/webhook-to-task/scripts/webhook-to-task.sh --stdin
```

### Mode 4: From file with explicit format

```bash
.github/skills/webhook-to-task/scripts/webhook-to-task.sh \
  --file /tmp/webhook-payload.json \
  --format linear
```

## Input Format

### GitHub Issues (`--format github`)

Expects JSON seperti GitHub Issues API response:
```json
{
  "title": "Blog page error 500",
  "body": "Halaman blog error 500...",
  "labels": [{"name": "bug"}, {"name": "P0"}]
}
```

Mapping:
- Label `bug`, `critical`, `P0` → priority P0
- Label `enhancement`, `feature`, `P1` → priority P1
- Label `chore`, `docs`, `P2` → priority P2

### Linear (`--format linear`)

Expects JSON seperti Linear webhook payload:
```json
{
  "data": {
    "issue": {
      "title": "Fix payment timeout",
      "priority": 1
    }
  }
}
```

Mapping priority: 0-1 → P0, 2 → P1, 3+ → P2.

## Integration with Orchestrator

Tasks received via webhook are immediately ready to be processed by `@orchestrator`.
The orchestrator will read queue.md, find new tasks with status `pending`,
and dispatch to the appropriate agent.

```
JSON payload (file/pipe) → webhook-to-task.sh → queue.md → orchestrator → agent loop
```
