# Task Queue & Orchestration

Task management via `.github/tasks/` — see `orchestrator.agent.md` for the full workflow.

## Queue Structure
- **Queue**: `.github/tasks/queue.md` — task list with priorities (P0 > P1 > P2).
- **Checkpoint**: `.github/tasks/session/current.md` — written by `checkpoint.prompt.md` for P0/P1 tasks.
- **Orchestrator**: `@orchestrator` — read-only agent that reads the queue, dispatches to the appropriate agent, and monitors progress.
- **Recovery**: new agent / new session must check `current.md` first before starting a new task.

## Flow

See the full diagram in [`instructions/feature-workflow.md`](./feature-workflow.md).

Queue → Orchestrator → Analyst → Implementer-be/-fe → Reviewer → Done/Blocked.

## Self-Healing

When a task fails, the orchestrator automatically classifies the error and performs recovery:

| Error | Deteksi | Recovery |
|---|---|---|
| **compile error** (Go) | `go build` fails | Auto-fix: call `@implementer-be` with the error message |
| **compile error** (FE) | `esbuild` fails | Auto-fix: call `@implementer-fe` with the error message |
| **test fail** (Go) | `go test` fails | Attempt 1: `@implementer-be` fix. Attempt 2: reviewer analyzes → `@implementer-be` fix. Max 3x. |
| **test fail** (FE) | `vitest` fails | Attempt 1: `@implementer-fe` fix. Attempt 2: reviewer analyzes → `@implementer-fe` fix. Max 3x. |
| **timeout** | Agent hangs | Retry 2x, then blocked |
| **unknown** | Unclear error | Blocked immediately, no retry |

```
Implementer → build/test? → yes → Reviewer
                → no  → compile Go → @implementer-be fix
                → no  → compile FE → @implementer-fe fix
                → no  → test fail  → retry (max 3) → blocked
                → no  → timeout    → retry → blocked
                → no  → unknown    → blocked
```

## Checkpoint (REQUIRED for P0/P1)

For P0/P1 tasks that have run >10 agent steps, the `implementer` MUST call `checkpoint.prompt.md`
to write progress to `.github/tasks/session/current.md` and commit.

**Enforcement:**
- If `@implementer` exceeds >30 steps without a checkpoint for a P0/P1 task,
  `@orchestrator` will block the task and force a checkpoint to be written before continuing.
- Checkpoints are NOT optional — they are mandatory for large tasks.

Checkpoints are useful because:
1. Context window doesn't fill up — agent can summarize and continue.
2. Multi-session tasks stay tracked — checkpoints are committed to git, not lost.
3. Recovery if agent crashes — new session just reads current.md and continues.

## Task Logging — MANDATORY Rules

**Every change to the project MUST be recorded in the task queue.**
This is not optional. All agents must follow this rule.

**Entry point:** `@orchestrator` is the sole entry point. All user requests
go through the orchestrator first, which will:
1. Log the task to `.github/tasks/queue.md`
2. Dispatch to the appropriate agent (analyst/implementer/reviewer)
3. Monitor progress and update queue status

If the user does not explicitly mention `@orchestrator`, it still auto-invokes
because `disable-model-invocation: false`.

### Who writes to the queue

| Situation | Responsible party |
|---|---|
| All user requests | **`@orchestrator`** — log in step 1, update at every milestone |
| Implementer finishes | Report to orchestrator — orchestrator updates queue + dispatches reviewer |
| Bug fix directly from orchestrator | Orchestrator logs to queue, then dispatches implementer |
| Chore/refactor | Orchestrator logs to queue, then dispatches implementer |

> If an agent (analyst/implementer) receives a request directly from the user
> without going through the orchestrator, that indicates incorrect routing. That agent
> must **stop and tell the user** to use `@orchestrator`.

## Agent Routing

| Prompt theme | Agent |
|---|---|
| **Entry point for all requests** — task queue, dispatch, progress, resume | `@orchestrator` (auto-invoke) |
| **Large** feature requests (many stakeholders, user roles), business analysis, user stories | `planner` |
| Feature analysis, clarify requirements, create technical spec | `analyst` |
| Implement feature, coding, bugfix, fix, refactor, create endpoint, create module | `implementer` |
| Review, code review, check architecture, module boundary, code review | `reviewer` |

> **IMPORTANT:** Do NOT call `@analyst`, `@implementer`, or `@reviewer` directly.
> All requests must go through `@orchestrator` first — it will log the task to the queue
> and dispatch to the appropriate agent.
