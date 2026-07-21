# Agent Guardrails

Policy constraints for all AI agents working in this repository.

## Enforcement

Guardrails are enforced via two mechanisms:

1. **Tool restriction** (enforced by VS Code) — see the `tools:` frontmatter in each `.agent.md`:
   - `reviewer`, `analyst`, `planner`: `read/readFile`, `search`, `execute/terminalLastCommand` only
     → **cannot edit files**.
   - `implementer`: full tools including `edit` and `runInTerminal`.
2. **Instructions** (expected to be followed) — the rules below.

## 1. Forbidden Topics

Agents MUST NOT generate, suggest, or discuss harmful, illegal, discriminatory, sexually explicit, or fake personal information.

If the user requests any of the above, respond with: *"Sorry, I can't assist with that."*

## 2. Security & Privacy

- Never expose secrets, credentials, API keys, or tokens.
- Do not generate PII (national ID, addresses, phone numbers) for dummy data — use clearly fictitious data.
- Do not commit, push, or suggest changes that weaken security (SQL injection, XSS, hardcoded secrets).

## 3. Operational

- Do not delete or modify `.db` database files directly — use the `db-migration` skill.
- Do not overwrite existing modules — use the `new-feature-module` skill only for new modules.
- **Before scaffolding a new module**, ensure `init-core.sh` has been run. If unsure, run:
  ```bash
  .github/skills/init-core-project/scripts/init-core.sh
  ```
- After writing code, run `go build ./... && go test ./...` to verify.

## 4. Architecture

- Do not import directly from another module's package — use public interfaces or promote to `core/`.
- Do not place React components in root `components/` if they are only used by one module.
- Do not split a feature's backend and frontend into different folders — keep them colocated in `modules/<feature>/`.

## 5. Checkpoint & Task Management

- Only write checkpoints for P0/P1 tasks running >10 agent steps — not for small tasks.
- Every checkpoint MUST be committed with the format: `chore: checkpoint <task> — <summary>`.
- **Checkpoint compliance:** Implementer MUST write a checkpoint for P0/P1 >10 steps.
  If >30 steps without a checkpoint, orchestrator will block the task until a checkpoint is written.
  Repeated violations → escalate to user.
- Orchestrator must not edit code — only read queue, dispatch, and write session/current.md.

## 6. Retry, Self-Healing & Blocked Tasks

- **Error classification:** Orchestrator MUST classify errors before deciding on recovery.
  - Compile error → auto-fix (call implementer).
  - Test fail → retry loop with reviewer analysis before attempt 2.
  - Timeout → retry max 2x, then blocked.
  - Unknown → blocked immediately, do not retry.
- **Attempt limit:** Max 3 attempts per task. Attempt 4 = blocked.
- **Blocked task:** Write a blocker file to `.github/tasks/blocked/` using the template.
  Do not retry a blocked task without user approval.
  Inform the user: "Task [name] blocked. See [file] for details."
- Do not start a new task before the current `in_progress` task is done or blocked.
