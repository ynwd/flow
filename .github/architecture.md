# Architecture

## Tech Stack

- Backend: Go (module: `github.com/ynwd/flow`)
- Frontend: React + TypeScript, bundled with **esbuild** via npm workspaces (each module has its own `esbuild.mjs`)
- Styling: **Tailwind CSS v4** via PostCSS (`npm run build:css`), CSS files in `core/static/css/`
- Server-rendered shell: Go `html/template` in `core/templates/`, hydrated by TS bundles
- Database: In-memory (`sync.RWMutex`), SQLite planned
- Assets (static files & templates) are embedded into the binary via `go:embed`
- IDs: ULID (`core/ulid/`)

## Project Structure

```
.
├── main.go                    # Entry point — blank-import modules/
├── go.mod
├── go.sum
│
├── core/                      # Shared platform/infra, NOT business logic
│   ├── router/
│   │   ├── router.go          # Route, Module interface, BuildRouter, RegisterModule
│   │   └── middleware.go      # middlewareForRoute() — compose access + rate limit
│   ├── middlewares/
│   │   ├── logging.go         # LoggingMiddleware — request logging
│   │   ├── private.go         # PrivateMiddleware — Bearer token auth
│   │   ├── sameorigin.go      # SameOriginMiddleware — Origin/Referer check
│   │   ├── ratelimit.go       # RateLimiter — per-IP sliding window
│   │   ├── ssr.go             # SSRMiddleware — server-side rendering support
│   │   └── middlewares_test.go# Table-driven tests for all middlewares
│   ├── static/
│   │   ├── embed.go           # go:embed static assets
│   │   ├── css/
│   │   │   ├── app.css        # Tailwind CSS v4 entry (source)
│   │   │   └── app.min.css    # Built output (npm run build:css)
│   │   └── placeholder.txt
│   ├── templates/
│   │   ├── embed.go           # go:embed templates
│   │   ├── render.go          # RenderSSR / RenderEmpty helpers
│   │   └── landing.html       # Fallback landing page (no modules registered)
│   └── ulid/
│       └── ulid.go            # ULID ID generator
│
├── modules/
│   ├── register.go            # Blank import all modules → trigger self-registration
│   └── <feature>/             # ONE FOLDER PER FEATURE — backend + frontend colocated
│       ├── module.go          # init() → router.RegisterModule() + Routes()
│       ├── handler.go         # HTTP handlers / route entrypoints
│       ├── service.go         # Business logic
│       ├── repository.go      # Data access (in-memory store)
│       ├── model.go           # Domain types/structs
│       ├── handler_test.go
│       ├── service_test.go
│       ├── package.json       # FE dependencies (react, typescript, vitest, ...)
│       ├── esbuild.mjs        # FE build config
│       ├── <Feature>.tsx      # FE entry component (user customizes this)
│       ├── <Feature>.test.tsx
│       ├── api.ts             # FE fetch client (list, create, update, delete)
│       ├── api.test.ts
│       ├── components/        # FE components specific to this feature only
│       ├── templates/
│       │   ├── shell.html     # HTML shell — head, CSS, React mount point
│       │   └── skeleton.html  # SSR skeleton — visible before React loads
│       └── static/
│           └── dist/
│               └── <feature>.bundle.js
│
├── cmd/
│   └── migrate/
│       └── main.go            # Migration CLI entry point
│
├── .core-state.json           # State tracking for init-core-project (see .gitignore)
├── .github/                   # AI Engineering & CI/CD
│   ├── copilot-instructions.md    # Instructions entry point — index to other files
│   ├── guardrails.md              # Security constraints
│   ├── architecture.md            # This document — project structure
│   ├── instructions/              # Modular instructions (loaded via copilot-instructions.md)
│   │   ├── architecture.md        # Module registration, boundaries, conventions
│   │   ├── task-orchestration.md  # Task queue, self-healing, checkpoint, routing
│   │   ├── feature-workflow.md    # Dev pipeline, wireframe, scaffold, step-by-step
│   │   ├── frontend-performance.md# Code splitting, caching, memoization
│   │   └── build-and-git.md       # Build commands, git workflow
│   ├── agents/
│   │   ├── orchestrator.agent.md  # ⚡ Entry point — task queue, dispatch, monitor
│   │   ├── implementer.agent.md   # ✏️ Writes code & terminal
│   │   ├── reviewer.agent.md      # 🔍 Reviews architecture & module boundary
│   │   ├── analyst.agent.md       # 📝 Analyzes requirements, creates spec
│   │   └── planner.agent.md       # 📋 Manual only — large user stories
│   ├── prompts/
│   │   ├── add-endpoint.prompt.md   # ➕ Add endpoint to existing module
│   │   ├── code-review.prompt.md    # 🔍 Review diff/PR against module-boundary rules
│   │   ├── explain-module.prompt.md # 💡 Explain one module end-to-end
│   │   └── checkpoint.prompt.md     # ⚡ Checkpoint session state
│   ├── tasks/                          # ⚡ Task queue & orchestration
│   │   ├── queue.md                    # Task queue with P0/P1/P2 priorities
│   │   ├── session/
│   │   │   ├── current.md              # Active checkpoint (committed)
│   │   │   └── archive/                # Checkpoint history
│   │   ├── done/                       # Completed tasks
│   │   └── blocked/                    # Tasks failed 3x (TEMPLATE.md for format)
│   └── skills/
│       ├── init-core-project/       # ⚡ Init core from template + state tracking
│       ├── new-feature-module/      # Scaffold feature module
│       ├── add-shared-component/    # Promote to shared component
│       ├── db-migration/            # Database migration
│       ├── feature-spec/           # Feature specification
│       ├── reset-tasks/            # 🔄 Reset task queue & checkpoint
│       └── webhook-to-task/        # 📥 Auto-trigger from issue tracker to queue
│
├── package.json               # workspaces: ["modules/<feature>", ...] + build:css
├── postcss.config.js          # PostCSS + @tailwindcss/postcss
├── vitest.config.ts           # Vitest config (jsdom)
├── vitest.setup.ts            # Vitest setup (@testing-library/jest-dom)
├── node_modules/              # npm workspaces — hoisted to root
└── README.md
```
