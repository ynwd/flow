# Flow — AI-Native Go + React Modular Monolith Framework

> **You describe it. AI builds it. You ship.**

[![Go](https://img.shields.io/badge/Go-1.24-00ADD8?logo=go)](https://go.dev)
[![React](https://img.shields.io/badge/React-18-61DAFB?logo=react)](https://react.dev)
[![TypeScript](https://img.shields.io/badge/TypeScript-5-3178C6?logo=typescript)](https://www.typescriptlang.org)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-4-06B6D4?logo=tailwindcss)](https://tailwindcss.com)
[![License](https://img.shields.io/badge/License-MIT-yellow)](#)

Go backend + React/TypeScript frontend in a modular monolith — with built-in AI agents, self-registering modules, SSR, and in-memory database.

---

## Quick Start

```bash
git clone --recurse-submodules <repo-url> && cd flow
make init && make run
open http://localhost:3000
```

> Prerequisites: Go 1.24+, Node.js 22+, Make. Already cloned? Run `git submodule update --init --recursive`.

---

## Create a Module

```bash
make scaffold name=blog ssr=--ssr
```

Generates colocated `modules/blog/` — backend (Go), frontend (React/TS), tests, templates. Register in `modules/register.go`, then `make run`. Live at `/blog`.

---

## Architecture

```
HTTP Request → Handler → Service → Repository → In-Memory Store
```

Modules self-register via `init()`. AI agents handle the dev pipeline:

```
User Request → @orchestrator → @analyst → @implementer → @reviewer → Done
```

| Agent | Role |
|---|---|
| `@orchestrator` | Task queue, dispatch |
| `@analyst` | Requirements → spec |
| `@implementer` | Go backend / React frontend |
| `@reviewer` | Architecture review |

### Shared Config

`.copilot/` submodule ([gatralaya/copilot](https://github.com/gatralaya/copilot)) — single source of truth for agents, skills, prompts. See [`.copilot/README.md`](.copilot/README.md).

| Location | Purpose |
|---|---|
| `.copilot/` | Shared config (agents, skills, instructions) |
| `.github/` | Repo-specific (workflows, tasks, specs) |

---

## Commands

| Command | Description |
|---|---|
| `make init` | Initialize core from templates |
| `make scaffold name=<name>` | Create new module |
| `make run` | Build + start server |
| `make test` | Go tests + Vitest |
| `make lint` | golangci-lint + ESLint |
| `make clean` | Remove generated files |
| `make sync` | Push `.copilot/` to upstream |
| `make sync-pull` | Pull latest `.copilot/` |

---

## Configuration

| Variable | Default | Description |
|---|---|---|
| `PORT` | `3000` | Server port |
| `HOST` | `0.0.0.0` | Server host |

Access: `AccessPublic`, `AccessPrivate` (Bearer), `AccessSameOrigin`. Rate limiting per-route.

---

## Tech Stack

Go 1.24 · React 18 · TypeScript 5 · Tailwind CSS v4 · ESBuild · Vitest · ULID

---

## Why Flow?

| Problem | Solution |
|---|---|
| Scattered files | **One folder per feature** — colocated |
| Manual routes | **Self-registration** via `init()` |
| Inconsistent style | **Skills** enforce conventions |
| Generic AI | **Tool-locked agents** with roles |
| External DB | **In-memory store** with TTL |
| SSR issues | **Skeleton HTML** fallback |

---

## Docs

| Document | Description |
|---|---|
| [Architecture](.copilot/architecture.md) | Structure & conventions |
| [Guardrails](.copilot/guardrails.md) | Security rules |
| [Contributing](CONTRIBUTING.md) | How to contribute |
| [Changelog](CHANGELOG.md) | Version history |

---

MIT License — see [LICENSE](LICENSE)

**Built with ❤️ by [ynwd](https://github.com/ynwd)**

