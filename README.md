# Flow — AI-Native Go + React Modular Monolith Framework

> **You describe it. AI builds it. You ship.**

Flow is an open-source, AI-native web framework that combines a **Go backend** with a **React + TypeScript frontend** in a modular monolith architecture. It's designed for rapid development with AI agents that understand your codebase conventions.

[![Go](https://img.shields.io/badge/Go-1.24-00ADD8?logo=go)](https://go.dev)
[![React](https://img.shields.io/badge/React-18-61DAFB?logo=react)](https://react.dev)
[![TypeScript](https://img.shields.io/badge/TypeScript-5-3178C6?logo=typescript)](https://www.typescriptlang.org)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-4-06B6D4?logo=tailwindcss)](https://tailwindcss.com)
[![License](https://img.shields.io/badge/License-MIT-yellow)](#)

---

## What is Flow?

Flow is a **full-stack web framework** for building modern web applications with:

- **Go backend** — HTTP handlers, services, repositories with in-memory storage (SQLite planned)
- **React 18 frontend** — TypeScript, Tailwind CSS v4, server-side rendering (SSR)
- **AI agent system** — Built-in orchestrator, analyst, implementer, and reviewer agents
- **Modular architecture** — Self-registering modules with colocated backend and frontend code

### Key Features

| Feature | Description |
|---|---|
| **Self-Registration** | Modules automatically register routes via Go's `init()` function — no manual wiring needed |
| **Colocated Code** | Each feature lives in one folder: `handler.go`, `service.go`, `repository.go`, `Blog.tsx`, `api.ts` |
| **AI Agents** | Built-in agents that understand your codebase: orchestrator, analyst, implementer, reviewer |
| **Server-Side Rendering** | Optional SSR with graceful fallback to client-side rendering |
| **In-Memory Database** | Fast development with `sync.RWMutex` — no external database required |
| **Type Safety** | Full TypeScript strict mode with React 18 and Go 1.24 |
| **Tailwind CSS v4** | Modern styling with dark/light theme support |
| **ESBuild Bundling** | Fast frontend builds with tree-shaking and code splitting |

---

## Quick Start

### Prerequisites

- **Go 1.24+** — [Install Go](https://go.dev/doc/install)
- **Node.js 22+** — [Install Node.js](https://nodejs.org/)
- **Make** — Build automation

### Installation

```bash
# Clone the repository
git clone <repo-url>
cd flow

# Initialize core project files
make init

# Start the development server
make run

# Open in browser
open http://localhost:3000
```

### What Happens

1. `make init` — Generates core files from templates (main.go, go.mod, core/, modules/)
2. `make run` — Builds Tailwind CSS, compiles React bundles, starts Go server
3. Server runs at **localhost:3000** with a landing page

---

## Creating Your First Module

### Scaffold a New Feature

```bash
make scaffold name=blog ssr=--ssr
```

This creates a complete module with:

```text
modules/blog/
├── handler.go           # HTTP handlers and route definitions
├── service.go           # Business logic layer
├── repository.go        # In-memory data storage with TTL and pagination
├── model.go             # Domain types and error definitions
├── module.go            # Self-registration via init()
├── handler_test.go      # HTTP handler tests
├── service_test.go      # Service layer tests
├── Blog.tsx             # React component (list, create, delete)
├── api.ts               # Frontend API client with caching
├── api.test.ts          # API client tests
├── Blog.test.tsx        # React component tests
├── esbuild.mjs          # Frontend build configuration
├── package.json         # Module dependencies
├── templates/
│   ├── shell.html       # HTML shell with CSS and React mount point
│   └── skeleton.html    # Server-side skeleton for loading states
└── static/dist/
    └── blog.bundle.js   # Compiled JavaScript bundle
```

### Register Your Module

Edit `modules/register.go`:

```go
package modules

import (
    _ "github.com/ynwd/flow/modules/blog"
    _ "github.com/ynwd/flow/modules/index"
)
```

### Build and Run

```bash
make run  # Rebuilds and restarts server
```

Your new module is now available at `http://localhost:3000/blog`.

---

## Architecture

### Module Structure

Each module follows a **layered architecture**:

```
HTTP Request → Handler → Service → Repository → In-Memory Store
```

- **Handler** — HTTP request/response handling, input validation
- **Service** — Business logic, data transformation
- **Repository** — Data access with TTL, pagination, and cleanup

### AI Agent System

Flow includes built-in AI agents that help you build features:

```
User Request → @orchestrator → @analyst → @implementer → @reviewer → Done
```

| Agent | Role |
|---|---|
| **@orchestrator** | Entry point — reads task queue, dispatches to agents |
| **@analyst** | Analyzes requirements, creates technical specifications |
| **@implementer** | Writes code (Go backend or React frontend) |
| **@reviewer** | Reviews code against architecture rules |

### Self-Registration Pattern

Modules register themselves automatically:

```go
// modules/blog/module.go
package blog

import "github.com/ynwd/flow/core/router"

func init() {
    router.RegisterModule(&BlogModule{})
}

type BlogModule struct{}

func (m *BlogModule) Name() string { return "blog" }
func (m *BlogModule) Routes() []router.Route {
    return []router.Route{
        {Method: "GET", Path: "/blog", Handler: ListHandler},
        // ... more routes
    }
}
```

No manual route registration needed — just blank-import the module.

---

## Commands Reference

| Command | Description |
|---|---|
| `make init` | Initialize core project from templates |
| `make scaffold name=<name>` | Create a new feature module |
| `make run` | Build CSS + React bundles + start server |
| `make test` | Run Go tests + Vitest (frontend) |
| `make lint` | Run golangci-lint (Go) + ESLint (TypeScript) |
| `make vet` | Run Go vet for static analysis |
| `make clean` | Remove all generated files and node_modules |
| `make help` | Show all available commands |

### Module-Specific Commands

```bash
# Build a specific module's frontend
npm run build -w modules/blog

# Watch mode for development
npm run watch -w modules/blog

# Run tests for a specific module
npx vitest run modules/blog
```

---

## Configuration

### Environment Variables

| Variable | Default | Description |
|---|---|---|
| `PORT` | `3000` | Server port |
| `HOST` | `0.0.0.0` | Server host |

### Rate Limiting

Configure per-route rate limiting:

```go
router.Route{
    Method:  "POST",
    Path:    "/api/blog",
    Handler: CreateHandler,
    Access:  router.AccessSameOrigin,
    RateLimit: &router.RateLimitConfig{
        RequestsPerSecond: 10, // 10 requests per second
    },
}
```

### Access Control

- **AccessPublic** — No authentication required
- **AccessPrivate** — Requires Bearer token
- **AccessSameOrigin** — Browser requests only (Origin/Referer check)

---

## Documentation

| Document | Description |
|---|---|
| [Architecture](.github/architecture.md) | Complete project structure and conventions |
| [Contributing](CONTRIBUTING.md) | How to contribute to Flow |
| [Security](SECURITY.md) | Security policy and vulnerability reporting |
| [Changelog](CHANGELOG.md) | Version history and updates |

---

## Tech Stack

| Component | Technology |
|---|---|
| **Backend** | Go 1.24 with standard library |
| **Frontend** | React 18, TypeScript 5, Tailwind CSS v4 |
| **Build** | ESBuild (frontend), Go build (backend) |
| **Bundling** | npm workspaces with per-module builds |
| **Testing** | Go testing, Vitest, React Testing Library |
| **Linting** | golangci-lint, ESLint with TypeScript |
| **ID Generation** | ULID (Universally Unique Lexicographically Sortable Identifier) |
| **Minification** | tdewolff/minify for HTML compression |

---

## Why Flow?

| Problem | Traditional Approach | Flow's Solution |
|---|---|---|
| File organization | Scattered across src/, components/, utils/ | **One folder per feature** — all code colocated |
| Route registration | Manual wiring in main.go | **Self-registration** via `init()` |
| Code style consistency | Manual enforcement, PR reviews | **Skills** — shell scripts enforce conventions |
| AI integration | Generic prompts, no context | **Tool-locked agents** with role-based access |
| Database setup | External database required | **In-memory store** with TTL and pagination |
| SSR complexity | Hydration mismatches | **Skeleton HTML** with graceful fallback |

---

## License

MIT License — see [LICENSE](LICENSE) for details.

---

**Built with ❤️ by [ynwd](https://github.com/ynwd) — AI-assisted development with Flow**

