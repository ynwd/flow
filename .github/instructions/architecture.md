# Architecture & Module Registration

## Tech Stack
- Backend: Go (module: `github.com/ynwd/flow`)
- Frontend: React + TypeScript, bundled with **esbuild** via npm workspaces
- Styling: **Tailwind CSS v4** via PostCSS
- Database: In-memory (`sync.RWMutex`), SQLite planned
- Assets (static files & templates) are embedded into the binary via `go:embed`
- IDs: ULID (`core/ulid/`)

## Project Structure
See **[architecture.md](./architecture.md)** for the full structure.

## Module Registration Pattern (IMPORTANT)

Each module registers itself automatically via a **self-registration pattern**:

1. `modules/<feature>/module.go` has a `func init()` that calls `router.RegisterModule(m)`.
2. `modules/register.go` imports the module with a blank import (`_ "github.com/ynwd/flow/modules/<feature>"`) — this is enough to trigger `init()`.
3. `main.go` only blank-imports `_ "github.com/ynwd/flow/modules"` — no need to know which modules exist.
4. `core/router/router.go` provides the `Module` interface (`Name()`, `Routes()`) and a `BuildRouter(mux)` function that calls routes for all modules.

### Adding / Removing Modules

> **Prerequisite:** Before adding a module, ensure the core project has been initialized.
> Run `init-core.sh` if not yet done:
> ```bash
> .github/skills/init-core-project/scripts/init-core.sh
> ```

- **Add**: run `.github/skills/new-feature-module/scripts/scaffold.sh <feature>`,
  then add a blank import to `modules/register.go` **and** add
  `"modules/<feature>"` to `workspaces` in the root `package.json`, then run
  `npm install` from the repo root.
- **Remove**: `rm -rf modules/<feature>` **and** remove the corresponding blank import from
  `modules/register.go` (do not leave an empty import block) **and** remove the entry
  `"modules/<feature>"` from `workspaces` in the root `package.json`.
  After that, run `go build ./... && go test ./... && go vet ./...` to
  ensure the project is still clean.

## Module Boundaries (IMPORTANT)

- All code for one feature — both Go and TSX — MUST be in `modules/<feature>/`. Do not split the same feature across multiple locations.
- One module MUST NOT import directly from another module's package. Use public interfaces or promote to `core/`.
- React components go in root `components/` ONLY if used by ≥2 modules. Default: put them in `modules/<feature>/components/`.
- `module.go` is the ONLY place where a module registers routes — via `init()` + `router.RegisterModule()`.
- Module name = one bounded context; do not create modules named "handlers" or "components".

## Conventions

### Go
- `gofmt`/`goimports`, Effective Go style.
- Wrap error: `fmt.Errorf("...: %w", err)`.
- Explicit dependency injection via constructors, avoid global state.
- Table-driven tests in `_test.go`, same package as the code.
- Use interfaces for mocking (RepositoryInterface, ServiceInterface).

### Frontend
- Strict mode, avoid `any`. Functional components + hooks only.
- API calls to the module's own backend MUST go through `api.ts`, do not `fetch` directly from components.
- Props typed explicitly; named exports for easier esbuild tracing.
- Testing: `vitest` + `@testing-library/react`; test files: `modules/<feature>/<Component>.test.tsx`.
- Build per-module via `npm run build -w modules/<feature>` (or `make run` builds all).
- Entry component rendered via `ReactDOM.createRoot` directly in the entry file.
- HTML shell template: `<div id="<feature>-root">` + `<script type="module" src="/static/<feature>/dist/<feature>.js">`.
- SSR skeleton: server renders simplified HTML → React replaces via `createRoot` (not `hydrateRoot`).
