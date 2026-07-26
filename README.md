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

**Prerequisites:** Go 1.24+, Node.js 22+, Make

```bash
git clone --recurse-submodules <repo-url>
cd flow
make init        # Generate core files from templates
make run         # Build CSS + bundles + start server
open http://localhost:3000
```

> Already cloned? Run `git submodule update --init --recursive` to fetch the `.copilot/` submodule.

---

## Creating a Module

```bash
make scaffold name=blog ssr=--ssr
```

This generates a colocated module at `modules/blog/` with:

| Layer | Files |
|---|---|
| **Backend** | `handler.go`, `service.go`, `repository.go`, `model.go`, `module.go` |
| **Frontend** | `Blog.tsx`, `api.ts`, `esbuild.mjs`, `package.json` |
| **Tests** | `handler_test.go`, `service_test.go`, `Blog.test.tsx`, `api.test.ts` |
| **Templates** | `shell.html`, `skeleton.html` |

Register in `modules/register.go`:

```go
import (
    _ "github.com/ynwd/flow/modules/blog"
    _ "github.com/ynwd/flow/modules/index"
)
```

Then `make run` — your module is live at `/blog`.

---

## Architecture

### Module Structure

```
HTTP Request → Handler → Service → Repository → In-Memory Store
```

Each module self-registers via Go's `init()`:

```go
func init() { router.RegisterModule(&BlogModule{}) }

func (m *BlogModule) Routes() []router.Route {
    return []router.Route{
        {Method: "GET", Path: "/blog", Handler: ListHandler},
    }
}
```

### AI Agents

```
User Request → @orchestrator → @analyst → @implementer → @reviewer → Done
```

| Agent | Role |
|---|---|
| `@orchestrator` | Entry point — task queue, dispatch |
| `@analyst` | Requirements → technical spec |
| `@implementer` | Code (Go backend / React frontend) |
| `@reviewer` | Architecture & boundary review |

### Shared Config (`.copilot/` submodule)

Source: [gatralaya/copilot](https://github.com/gatralaya/copilot) — see [`.copilot/README.md`](.copilot/README.md) for full docs.

| Location | Contents | Purpose |
|---|---|---|
| `.copilot/` | agents, skills, prompts, instructions, guardrails | Shared config (single source of truth) |
| `.github/` | workflows, tasks, specs | Repo-specific state (mutable) |

---

## Commands

| Command | Description |
|---|---|
| `make init` | Initialize core from templates |
| `make scaffold name=<name>` | Create new feature module |
| `make run` | Build + start server |
| `make test` | Go tests + Vitest |
| `make lint` | golangci-lint + ESLint |
| `make clean` | Remove generated files |
| `make sync` | Push `.copilot/` changes to upstream |
| `make sync-pull` | Pull latest from upstream `.copilot/` |
| `make sync-status` | Check sync status |

---

## Configuration

| Variable | Default | Description |
|---|---|---|
| `PORT` | `3000` | Server port |
| `HOST` | `0.0.0.0` | Server host |

**Access control:** `AccessPublic` (no auth), `AccessPrivate` (Bearer token), `AccessSameOrigin` (browser only). Rate limiting configurable per-route.

---

## Tech Stack

| Component | Technology |
|---|---|
| Backend | Go 1.24 (standard library) |
| Frontend | React 18, TypeScript 5, Tailwind CSS v4 |
| Build | ESBuild (frontend), Go build (backend) |
| Testing | Go testing, Vitest, React Testing Library |
| ID | ULID |

---

## Documentation

| Document | Description |
|---|---|
| [Architecture](.copilot/architecture.md) | Project structure & conventions |
| [Guardrails](.copilot/guardrails.md) | Security & operational rules |
| [Contributing](CONTRIBUTING.md) | How to contribute |
| [Changelog](CHANGELOG.md) | Version history |

---

## Why Flow?

| Problem | Flow's Solution |
|---|---|
| Scattered files | **One folder per feature** — all code colocated |
| Manual route wiring | **Self-registration** via `init()` |
| Inconsistent code style | **Skills** — shell scripts enforce conventions |
| Generic AI prompts | **Tool-locked agents** with role-based access |
| External DB required | **In-memory store** with TTL and pagination |
| SSR hydration issues | **Skeleton HTML** with graceful fallback |

---

MIT License — see [LICENSE](LICENSE)

**Built with ❤️ by [ynwd](https://github.com/ynwd)**

