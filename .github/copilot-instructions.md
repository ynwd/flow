# Repository Custom Instructions

Project-wide guidelines applied to every interaction.

> **IMPORTANT — Routing Rules for Default Agent:**
>
> **CORE FLOW (new feature / new module):**
> Do NOT dispatch to subagent. You (default agent) execute the flow directly:
> 1. Log task to `.github/tasks/queue.md`
> 2. Ask requirements via `vscode_askQuestions` (Batch 1-3, see `analyst.agent.md`)
> 3. Write spec to `.github/specs/<feature>.md`
> 4. Run `scaffold.sh` based on answers
> 5. Update queue to done
>
> See `instructions/feature-workflow.md` for the full pipeline.
>
> **DISPATCH TO SUBAGENT (only for specific tasks):**
> - If user asks to **add endpoint to existing module** or **backend/frontend implementation**: dispatch to `@implementer-be` or `@implementer-fe`.
> - If user asks to **review code / PR**: dispatch to `@reviewer`.
> - If user asks for **analysis / spec / self-clarity** (not part of the new feature flow): dispatch to `@analyst`.
>
> **OPERATIONAL (execute directly, no dispatch):**
> - Init core, clean root, squash, migration, reset task, explain module → run skill directly.

## Reference Files

| File | Covers |
|---|---|
| `instructions/architecture.md` | Architecture, module registration, module boundaries, Go & FE conventions |
| `instructions/task-orchestration.md` | Task queue, orchestration flow, self-healing, checkpoint, task logging, agent routing |
| `instructions/feature-workflow.md` | Feature dev pipeline, wireframe/UI design, scaffold questions, step-by-step workflow |
| `instructions/frontend-performance.md` | Code splitting, tree shaking, caching, memoization, bundle analysis |
| `instructions/build-and-git.md` | Build/test commands, git workflow |
| `guardrails.md` | Security rules, forbidden topics, operational guardrails |
| `architecture.md` | Complete project structure diagram |

## Skills & Triggers

| Trigger keywords | Action | Skill file |
|---|---|---|
| Init core, init project, core files, reset core, template core | **Direct** — run skill | `.github/skills/init-core-project/SKILL.md` |
| New feature, new module, new module, scaffold, create feature | **Default agent executes directly** — queue → askQuestions → spec → scaffold | `.github/skills/new-feature-module/SKILL.md` |
| Feature spec, feature analysis, specification, clarify requirement | **Default agent executes directly** — ask user → write spec | `.github/skills/feature-spec/SKILL.md` |
| UI sketch, wireframe, UI sketch, custom UI, layout design | **Default agent executes directly** — ask user → analyze → write UI manifest | `.github/skills/feature-spec/SKILL.md` (section UI Design) |
| Shared component, promote component, move to shared | **Direct** — run skill | `.github/skills/add-shared-component/SKILL.md` |
| Card component, modal card, wizard card, step form container | **Direct** — run skill | `.github/skills/add-card-component/SKILL.md` |
| Migration, database schema, add table, alter column, db change | **Direct** — run skill | `.github/skills/db-migration/SKILL.md` |
| Clean root, clean root, reset project, delete all core/modules files | **Direct** — run skill | `.github/skills/clean-root/SKILL.md` |
| Reset task queue, clean queue, delete checkpoint, reset tasks | **Direct** — run skill | `.github/skills/reset-tasks/SKILL.md` |
| Webhook, auto-trigger, issue to task, from Linear/GitHub to queue | **Direct** — run skill | `.github/skills/webhook-to-task/SKILL.md` |
| Task queue, orchestrator, dispatch, resume, checkpoint | **Direct** | `.github/agents/orchestrator.agent.md` |
| Checkpoint, save progress, session state | **Direct** | `.github/prompts/checkpoint.prompt.md` |
| Add endpoint, new route, add endpoint to existing module | **Direct** | `.github/prompts/add-endpoint.prompt.md` |
| Backend Go implementation, memory/GC, repository, service, handler | Dispatch to `@implementer-be` | `.github/agents/implementer-be.agent.md` |
| Frontend React/TS implementation, Tailwind, components, api.ts | Dispatch to `@implementer-fe` | `.github/agents/implementer-fe.agent.md` |
| Review diff, review PR, code review, check module boundary | Dispatch to `@reviewer` | `.github/prompts/code-review.prompt.md` |
| Explain module, how it works, end-to-end flow | **Direct** | `.github/prompts/explain-module.prompt.md` |
| Squash commit, clean git history, combine commits | **Direct** — run skill | `.github/skills/squash-commits/SKILL.md` |

> **Correct order after cloning repo:**
> 0. `clean-root` (if cleanup needed after experimentation)
> 1. `init-core-project` — create all core files from template (state: skip if already exists)
> 2. `new-feature-module` — scaffold module (checks core state first)
>
> Scaffold produces a functional out-of-the-box module with in-memory store,
> full CRUD API, React UI, and tests — no manual editing needed. Just register, build, and test.

## Quick Reference

### Guardrails (Agent Capabilities)

| Agent | Tools | Can edit? | Auto-invokable? | Entry point? |
|---|---|---|---|---|
| `@orchestrator` | `read, search, edit` — `.github/tasks/` only | ✅ `.github/tasks/` only | ✅ Yes | ✅ **YES** |
| `@implementer` (index) | `execute, read, edit, search` | ✅ Yes | ✅ Yes | ❌ |
| `@implementer-be` (backend) | `execute, read, edit, search` | ✅ Yes | ✅ Yes | ❌ |
| `@implementer-fe` (frontend) | `execute, read, edit, search` | ✅ Yes | ✅ Yes | ❌ |
| `@reviewer` | `read, search, agent` | ❌ No | ✅ Yes | ❌ |
| `@analyst` | `read, search` | ❌ No | ✅ Yes | ❌ |
| `@planner` | `read, search` | ❌ No | ❌ No | ❌ |

- **Default agent**: for **new feature / new module**, default agent executes the flow directly (queue → askQuestions → spec → scaffold).
- **`@orchestrator`**: entry point for operational requests (init core, clean root, squash, migration).
- **`@implementer`** (index): router for full-stack tasks — reads then routes to `implementer-be` or `implementer-fe`.
- **`@implementer-be`**: specializes in **backend Go** — handler, service, repository, memory/GC, template.
- **`@implementer-fe`**: specializes in **frontend React/TS** — components, Tailwind, API, esbuild.
- **`@reviewer`** & **`@analyst`**: read-only, can auto-invoke or be called manually.
- **`@planner`**: manual only (`disable-model-invocation: true`).

### Task Queue Quick Rules

1. Orchestrator works on the highest priority task with status `pending`.
2. Only one task can be `in_progress` at a time.
3. Task done → move to `.github/tasks/done/<date>-<task>.md`.
4. Task failed 3x → move to `.github/tasks/blocked/<task>.md`.
5. Active checkpoint at `.github/tasks/session/current.md`.

> For the full guide, see the relevant file from the **Reference Files** table above.
