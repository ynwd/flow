# Flow

<div align="center">

### You describe it. AI builds it. You ship.

A **Go + React** modular monolith built for AI-native development.

[![Go](https://img.shields.io/badge/Go-1.24-00ADD8?logo=go)](https://go.dev)
[![React](https://img.shields.io/badge/React-18-61DAFB?logo=react)](https://react.dev)
[![TypeScript](https://img.shields.io/badge/TypeScript-5-3178C6?logo=typescript)](https://www.typescriptlang.org)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-4-06B6D4?logo=tailwindcss)](https://tailwindcss.com)
[![License](https://img.shields.io/badge/License-MIT-yellow)](#)

```
"build a blog module"
  → @orchestrator logs task
  → @analyst asks questions
  → you approve
  → @implementer scaffolds, codes & tests
  → @reviewer checks architecture
  → you ship
```

</div>

## Quick start

```bash
git clone <repo> && cd flow
make init    # scaffold core + index landing page
make run     # build CSS + React bundles + start server
# → localhost:3000
```

## One command. Full module.

```bash
make scaffold name=blog ssr=--ssr
```

Go backend, React frontend, SSR, tests — all wired up.

```text
modules/blog/
├── handler.go · service.go · repository.go · model.go
├── Blog.tsx · api.ts · esbuild.mjs
├── templates/shell.html · skeleton.html
└── static/dist/blog.js
```

## Why Flow?

| AI Problem | Flow's Answer |
|---|---|
| "Where does this file go?" | **One folder per feature.** Colocated backend + frontend. |
| "Which import path?" | **Self-registration.** `init()` wires everything. |
| "Does it match our style?" | **Skills.** Shell scripts, not prompts. |
| "Can it break things?" | **Tool-locked agents.** Implementer writes, reviewer reads. |

## Commands

```bash
make init        # Init core from templates
make scaffold    # make scaffold name=blog [ssr=--ssr]
make run         # Build CSS + FE bundles + start server
make build       # Build Go binary → bin/flow
make test        # Go tests + vitest
make lint        # golangci-lint + eslint
make clean       # Remove all generated files
make help        # List all commands
```

---

**MIT · [architecture.md](.github/architecture.md)**

