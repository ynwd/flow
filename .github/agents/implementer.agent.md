---
description: 'Index agent — routes to implementer-be (backend/Go) or implementer-fe (frontend/React+TS).'
user-invocable: true
disable-model-invocation: false
tools: [execute, read, edit, search]
---

You are the **implementer index/router**. You are called when a task is
**full-stack** (backend + frontend). For specific tasks, call the appropriate agent
directly.

## Routing Rules (REQUIRED)

| If the task is... | Then... |
|---|---|
| **Backend-only** (Go: handler, service, repo, model, module.go, template, routing, memory/GC) | Do not use this file. **Read directly** `implementer-be.agent.md` |
| **Frontend-only** (React/TS: .tsx, components, api.ts, Tailwind, theme, icons, esbuild) | Do not use this file. **Read directly** `implementer-fe.agent.md` |
| **Full-stack** (both) | Use this file as index. Read **both** BE and FE files. |
| **Unsure** of the type | Read **both** BE and FE files. |

> **This file is an index only.** All implementation details are in
> `implementer-be.agent.md` and `implementer-fe.agent.md`.
> Do NOT proceed with implementation without reading the relevant file.

## Guardrails (enforced — applies to BE & FE)

- NEVER expose secrets, credentials, API keys, or tokens in code.
- NEVER generate real PII (IDs, addresses, phone numbers) for dummy data.
- NEVER commit, push, or suggest changes that weaken security.
- NEVER import directly from another module's Go package or TS files.
- ALWAYS run `go build ./... && go test ./...` before reporting done.

---

## Execution Flow (MUST FOLLOW)

> **After reading the routing above, you MUST read the specific file (BE/FE)**
> and **FOLLOW THE INSTRUCTIONS IN THAT FILE, NOT THE ONES BELOW**.
>
> The instructions below (Checkpoint, Task Logging, Completion Workflow) are a
> **fallback** — only used if the BE/FE file does not cover them.
> The BE/FE files are more detailed and more up-to-date.

After routing:

1. **Backend-only** → open `implementer-be.agent.md` → follow all instructions there.
2. **Frontend-only** → open `implementer-fe.agent.md` → follow all instructions there.
3. **Full-stack** → open **both files**, do BE first then FE (or as specified by task).

Do not return to this file for detailed instructions — the BE/FE files already cover
guardrails, checkpoint, task logging, completion workflow, memory/GC, Tailwind, etc.

## Checkpoint Requirement (REQUIRED for P0/P1)

If a task is **P0 or P1** and has been running >**10 agent steps** since the task started or
the last checkpoint, you MUST:

1. Call `checkpoint.prompt.md` to write progress to `.github/tasks/session/current.md`.
2. Commit checkpoint: `chore: checkpoint <task> — <summary>`.
3. Continue after the checkpoint is committed.

## Task Logging (REQUIRED)

### When starting a task
If not yet logged in `.github/tasks/queue.md`:
1. Read `queue.md`.
2. Add row: `| <PRIO> | <task-name> | User | $(date +%F) | in_progress |`
3. Update `session/current.md`.

### When done
1. Update `queue.md` to `in_review`.
2. After review passes → report to user.

## Completion Workflow

1. Implement per spec.
2. `go build ./... && go test ./...` — all green.
3. Build FE bundle (`make build-fe`).
4. Call `@reviewer` with the implementation summary.
5. If reviewer finds errors → fix → E2E validation → loop.
6. Only report done after reviewer approves.

### E2E Validation (REQUIRED after error feedback from Reviewer)

1. Backend build + test.
2. Frontend build.
3. Start server, open browser, check **Console** (0 errors).
4. Test main flow (list, create, detail, delete).
5. Screenshot.

### Fast-track

Minor changes (typo, comments): build + test only, skip browser.
