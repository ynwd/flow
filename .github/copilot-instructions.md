# Repository Custom Instructions — Thin Wrapper

> **All shared config (skills, agents, prompts, instructions, guardrails, architecture)**
> **lives in the `.copilot/` submodule** (`https://github.com/gatralaya/copilot`).
>
> **This file exists so VS Code Copilot finds instructions at the standard `.github/` path.**
> **The canonical source is `.copilot/copilot-instructions.md`.**

## How This Works

| What | Location | Purpose |
|---|---|---|
| **Shared config** (skills, agents, prompts, instructions, guardrails, architecture) | `.copilot/` | Submodule — single source of truth, shared across repos |
| **Repo-specific state** (task queue, specs, CI/CD workflows) | `.github/` | Mutable, lives only in this repo |

## Quick Reference

- **Full instructions**: see `.copilot/copilot-instructions.md`
- **Guardrails**: see `.copilot/guardrails.md`
- **Architecture**: see `.copilot/architecture.md`
- **Skills**: see `.copilot/skills/`
- **Agents**: see `.copilot/agents/`
- **Prompts**: see `.copilot/prompts/`
- **Task queue**: see `.github/tasks/queue.md`
- **Specs**: see `.github/specs/`
- **CI/CD**: see `.github/workflows/`
