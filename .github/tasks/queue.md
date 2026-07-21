# Task Queue

Format: `[PRIO] task | requested_by | date | status`

| Prio | Task | Requested | Date | Status |
|---|---|---|---|---|
| — | — | — | — | — |

## Priority Levels

- **P0** — Critical: bug, broken build, production issue. Must be handled immediately.
- **P1** — Feature: new module, new endpoint, enhancement. Default for feature requests.
- **P2** — Chore: refactor, dependency update, tech debt, minor improvement.

## Rules

1. Orchestrator works on the highest priority task with status `pending`.
2. Only one task can be `in_progress` at a time — do not start a new task before the current one is done or blocked.
3. When a task is done → move the row to `.github/tasks/done/<date>-<task>.md`.
4. When a task fails 3x → move to `.github/tasks/blocked/<task>.md` + log reason.
5. Active checkpoint is at `.github/tasks/session/current.md`.
