---
name: new-feature-module
description: Scaffold a new feature module for this repo — creates a modules/<feature>/ folder with colocated Go backend files (handler.go, service.go, repository.go, model.go, module.go) and TypeScript/React frontend files (<Feature>.tsx, components/, api.ts). Use this whenever the user asks to add a new feature, module, or page — do not hand-write the boilerplate, run the scaffold script instead.
---

# New Feature Module

This repo follows a **one module = one feature = backend + frontend colocated** pattern
(see `.github/copilot-instructions.md` for the full architecture rules). This skill
scaffolds a new `modules/<feature>/` folder with the standard set of files, correctly
named and wired, so a new feature always starts from the same shape.

## When to use this

Use this skill whenever the request is to add a **new feature/module** to the app —
e.g. "create a new billing feature", "add a new module called notifications", "scaffold
a payment feature". Do NOT use it to add a file to an *existing* module — only for
brand new ones.

## How to run it

There are two modes: **non-interactive** (CLI arguments) and **interactive** (step-by-step guide).

### Non-interactive mode

```bash
.github/skills/new-feature-module/scripts/scaffold.sh <feature-name> [--ssr] [layers...]
```

**Note:** Run this from the repo root (the directory containing `modules/`, `core/`, etc.).

**Prerequisite:** Ensure the core project has been initialized first via the `init-core-project` skill.
If not, run:
```bash
.github/skills/init-core-project/scripts/init-core.sh
```
Scaffold will refuse to run if any core files have not been created yet.

- `<feature-name>` must be lowercase, singular, kebab-case if multi-word (e.g. `billing`,
  `user-review`, `order-tracking`). This becomes the folder name under `modules/` and the
  Go package name (dashes are converted to no-separator for the Go package, e.g.
  `order-tracking` → package `ordertracking`).
- The script is idempotent-safe: it refuses to run if `modules/<feature-name>/` already
  exists, so it never overwrites a real feature.

**Options:**
- `--ssr` — Enable Server-Side Rendering for all page routes (SEO-friendly).  
  Without this flag, pages are CSR-only.
- `-i`, `--interactive` — Interactive mode: step-by-step guide (see below).

**Layers** (single-letter codes, can be combined — default = all layers):

| Kode | Layer | Files |
|---|---|---|
| `h` | handler | `handler.go`, `handler_test.go` |
| `s` | service | `service.go`, `service_test.go` |
| `r` | repository | `repository.go` |
| `m` | model | `model.go` |
| `p` | page | `templates/shell.html`, `templates/detail.html` |
| `f` | frontend | `<Feature>.tsx`, `api.ts`, `esbuild.mjs`, `package.json`, tests |

### Interactive mode

Run with the `-i` or `--interactive` flag:

```bash
.github/skills/new-feature-module/scripts/scaffold.sh -i
```

The script will guide you step-by-step:

```
Step 1: Nama fitur
  Masukkan nama fitur (lowercase, kebab-case): blog

Step 2: Pilih layer
  Available layers: h(handler) s(service) r(repo) m(model) p(page) f(frontend)
  Default (all layers): [Enter]
  Or choose a combination (e.g.: h s r m): h s r m p f

Step 3: Akses per endpoint
  Each endpoint can have its access configured:

  Page routes (GET):
    /blog          → [public / private / same-origin] (default: public):
    /blog/{id}     → [public / private / same-origin] (default: public):

  API routes:
    POST /api/blog → [public / private / same-origin] (default: same-origin):
    GET /api/blog  → [public / private / same-origin] (default: same-origin):
    GET /api/blog/{id} → [public / private / same-origin] (default: same-origin):
    PUT /api/blog/{id} → [public / private / same-origin] (default: same-origin):
    DELETE /api/blog/{id} → [public / private / same-origin] (default: same-origin):

Step 4: SSR per page
  Which pages need Server-Side Rendering (SEO-friendly)?

    /blog          → SSR? [y/N] (default: N):
    /blog/{id}     → SSR? [y/N] (default: N):

Step 5: Rate limit per write endpoint
  Write endpoints (POST, PUT, DELETE) can have a rate limit (req/s).
  Default: 10 req/s. Leave empty for no limit.

    POST /api/blog   → Rate limit (req/s) [10]:
    PUT /api/blog/{id} → Rate limit (req/s) [10]:
    DELETE /api/blog/{id} → Rate limit (req/s) [10]:

=== SUMMARY ===
Feature: blog
Layers: handler, service, repository, model, page, frontend
Routes:
  GET  /blog          (public, SSR)
  GET  /blog/{id}     (public, SSR)
  POST /api/blog      (same-origin, rate: 10/s)
  GET  /api/blog      (same-origin)
  GET  /api/blog/{id} (same-origin)
  PUT  /api/blog/{id} (same-origin, rate: 10/s)
  DEL  /api/blog/{id} (same-origin, rate: 10/s)

Proceed? [Y/n]:
```

**Non-interactive examples:**

```bash
scaffold.sh task                # all layers, CSR (default)
scaffold.sh task --ssr          # all layers, SSR
scaffold.sh billing --ssr h p f # landing page with SSR + FE
scaffold.sh billing h s r m     # backend API only
scaffold.sh notify h s          # handler + service
scaffold.sh ping h              # handler only
scaffold.sh about h p f         # CSR landing page with FE
scaffold.sh dashboard h p f     # frontend CSR with FE
```

## What it creates

```
modules/<feature-name>/
├── handler.go              # HTTP handlers — full CRUD + Page (HTML)
├── service.go               # business logic
├── repository.go             # data access (in-memory store)
├── model.go                   # domain struct
├── router.go                   # route definitions (Routes()) — page via GET /<feature>
├── module.go                    # self-registration via init()
├── esbuild.mjs                  # FE: build config for bundling
├── package.json                 # FE: react, react-dom, esbuild, typescript
├── templates/
│   ├── shell.html               # HTML page with <div id="<feature>-root"> + <script>
│   ├── skeleton-list.html       # SSR: server-rendered card HTML (from Go template)
│   └── skeleton-detail.html     # SSR: server-rendered detail HTML (from Go template)
├── static/
│   └── dist/
│       └── <feature>.bundle.js  # FE: bundled JS (auto-built by scaffold)
├── handler_test.go             # BE: table-driven test for HTTP handlers (httptest)
├── service_test.go             # BE: table-driven test for business logic
├── <Feature>.tsx               # FE entry component — renders via createRoot
├── <Feature>.test.tsx          # FE: component test (vitest + @testing-library/react)
├── api.ts                      # FE fetch client
├── api.test.ts                 # FE: fetch client test (vitest, mock fetch)
└── components/                 # empty, for FE components local to this feature
```

## After scaffolding

The scaffold auto-registers the module in `modules/register.go`, adds it to root
`package.json` workspaces, runs `npm install`, and builds the frontend bundle.
No manual steps needed.

Before running the server, build Tailwind CSS:

```bash
npm run build:css              # build Tailwind CSS
npm run build -w modules/<feature-name>  # build frontend bundle
go test ./modules/<feature-name>/... -v  # run backend tests
npx vitest run modules/<feature-name>/   # run frontend tests
go run .                                 # start server → visit /<feature-name>
```

## Validation (complete all these steps before production build)

### 1. Linter

```bash
golangci-lint run ./...
npx eslint 'modules/**/*.{ts,tsx}'
```

### 2. Unit test

**Backend:**
```bash
go test ./modules/<feature-name>/... -v
```

**Frontend (vitest):**
```bash
npx vitest run modules/<feature-name>/
```

### 3. End-to-end test

Start the server, then verify the API and browser page:

```bash
go run . &
sleep 2
```

**Cek API:**

```bash
# POST - create new item
curl -s -X POST http://localhost:3000/api/<feature-name> \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Item"}' | jq .

# GET - list all items
curl -s http://localhost:3000/api/<feature-name> | jq .

# PATCH - update status
curl -s -X PATCH http://localhost:3000/api/<feature-name>/<id>/status \
  -H "Content-Type: application/json" \
  -d '{"status":"done"}' | jq .

# DELETE - delete item
curl -s -X DELETE http://localhost:3000/api/<feature-name>/<id> | jq .
```

**Check page in browser:**
Open `http://localhost:3000/<feature-name>` — ensure the HTML page with React
app loads (has form input and Add button).

**Stop server after done:**
```bash
kill %1
```

### 4. Production build

After all tests pass, build:

```bash
npm run build -w modules/<feature-name>
```

> The scaffold generates a fully functional CRUD module out-of-the-box with an in-memory
> store, an HTML page route, and full React UI. Customize `model.go` with real fields,
> update `handler.go`/`service.go`/`repository.go` with real logic, and replace the
> in-memory store with a database when ready.
>
> If this feature needs a shared component or shared infra, follow the boundary rules in
> `.github/copilot-instructions.md` (default to keeping it inside the module first).
> If the feature needs custom hooks, add a `hooks.ts` file in the module folder manually.

## SSR (Server-Side Rendering)

By default, the scaffold generates **CSR (Client-Side Rendering)** pages — React renders
everything in the browser. To enable SSR (SEO-friendly), pass the `--ssr` flag:

```bash
scaffold.sh blog --ssr      # blog page with SSR
scaffold.sh blog --ssr h p f  # landing page only with SSR
```

### How SSR works

1. When `--ssr` is passed, the page route gets `SSR: true` in `router.go`
2. Go handler calls `service.List()` / `service.GetByID()` on the server to fetch data
3. **`templates.RenderSSR()`** does two things:
   - Renders **skeleton HTML** from data using Go templates (`skeleton-list.html`, `skeleton-detail.html`) — user sees actual content immediately
   - Serializes data as JSON into `window.__INITIAL_DATA__` for React hydration
4. React uses **`hydrateRoot`** instead of `createRoot` — attaches event listeners to existing DOM without re-rendering
5. If data fetch fails → `templates.RenderEmpty()` renders template without data (graceful degradation)

No "blank page" flash. No loading spinner needed. Users see content immediately, React adds interactivity.

### Disable SSR per route

Edit the route in your module's `router.go`:

```go
// SSR off (CSR)
{Method: "GET", Path: "/internal", Handler: handler.Page, Access: router.AccessPublic},

// SSR on
{Method: "GET", Path: "/blog", Handler: handler.Page, SSR: true, Access: router.AccessPublic},
```

### Add SSR to a route manually

In your module's `router.go`:

```go
{Method: "GET", Path: "/blog", Handler: handler.Page, SSR: true, Access: router.AccessPublic},
```

Handler already has `Page()` and `PageDetail()` that call `templates.RenderSSR()`
with skeleton rendering. The template reads `.InitialHTML` for server content and
`.InitialDataJSON` for React hydration.

## Templates

The literal file templates used by the script are in the same folder as `SKILL.md`
(`.github/skills/new-feature-module/*.tmpl`) if you need to inspect or hand-edit the
boilerplate shape without running the script.
