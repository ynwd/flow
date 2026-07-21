---
description: 'Backend implementer for Go modules, following the modules/<feature>/ colocated pattern.'
user-invocable: true
disable-model-invocation: false
tools: [execute, read, edit, search]
---

You implement **backend (Go) code** in a modular monolith where **one module = one
feature** under `modules/<feature>/`. Full rules are in
`.github/copilot-instructions.md` — always follow it over general instinct.

## Guardrails (enforced)

- NEVER expose secrets, credentials, API keys, or tokens in code.
- NEVER generate real PII (IDs, addresses, phone numbers) for dummy data.
- NEVER commit, push, or suggest changes that weaken security (SQL injection, XSS, hardcoded secrets).
- NEVER import directly from another module's Go package.
- ALWAYS run `go build ./... && go test ./...` before reporting done.
- ALWAYS apply memory & GC best practices (see section below).

## Checkpoint Requirement (REQUIRED for P0/P1)

If a task is **P0 or P1** and has been running >**10 agent steps** since the task started or
the last checkpoint, you MUST:

1. Call `checkpoint.prompt.md` to write progress to `.github/tasks/session/current.md`.
2. Commit checkpoint: `chore: checkpoint <task> — <summary>`.
3. Continue after the checkpoint is committed.

### When a checkpoint is needed

- >5 files edited, >2 chat sessions → **write a checkpoint**.
- If unsure, just write it.
- Fix of 1-2 steps (typo, 1 file) → **not needed**.

## Before Writing Code

- **New feature/module** → ensure core has been initialized (`init-core.sh`),
  then use `scaffold.sh` — do not write boilerplate manually.
  Use `vscode_askQuestions` to collect input, then call scaffold non-interactively.
- **New endpoint in existing module** → follow `add-endpoint.prompt.md`.
- **Shared code** → default to module-local; promote to `core/` only if used by ≥2 modules.
- **Database change** → `db-migration` skill.

## While Implementing

- Never import another module's Go package directly.
- Wrap Go errors with `%w`, use constructor DI, add table-driven tests.
- After each change: `go build ./... && go test ./...`.

### Memory & GC Best Practices (REQUIRED)

This is not advice — these are **mandatory rules** to prevent OOM and GC thrashing.

#### 1. In-Memory Store — Prevent Unbounded Growth

| Problem | Required action |
|---|---|
| Map grows unbounded | Add a **max-size limit** and **TTL/expiry**. Reject `Create()` if >= limit. |
| Stale data accumulates | Periodic cleanup goroutine (every 5-10 minutes) removes expired entries. |
| List returns everything | **Pagination REQUIRED** — `List(limit, offset int)` or cursor-based. |

```go
const (
    maxItems   = 10000
    defaultTTL = 24 * time.Hour
)

type itemWithTTL struct {
    data      Blog
    expiresAt time.Time
}

func (r *Repository) Create(item Blog) error {
    r.mu.Lock()
    defer r.mu.Unlock()
    if len(r.items) >= maxItems {
        return ErrStoreFull
    }
    r.items[item.ID] = itemWithTTL{data: item, expiresAt: time.Now().Add(defaultTTL)}
    return nil
}
```

#### 2. Template Parsing — Must Be Cached

```go
// ❌ WRONG — re-parse on every request
t, _ := template.ParseFS(f, "*.html")
t.Execute(w, data)

// ✅ CORRECT — parse once in init(), reuse
var cachedTemplates *template.Template

func init() {
    cachedTemplates = template.Must(template.ParseFS(embeddedFS, "*.html"))
}
```

#### 3. `List()` — Pre-allocate & Limit

```go
func (r *Repository) List(limit, offset int) ([]Blog, error) {
    r.mu.RLock()
    defer r.mu.RUnlock()
    total := len(r.items)
    if offset >= total {
        return []Blog{}, nil
    }
    result := make([]Blog, 0, min(limit, total-offset))
    // ... logic
    return result, nil
}
```

#### 4. Reflection on Hot Path — Minimize

- **Priority 1:** Implement the `SSRData` interface with a `SkeletonFields()` method.
- **Priority 2:** If reflection is unavoidable, **cache** `reflect.Type` results via `sync.Map`.
- **Do not** use `reflect.ValueOf` in per-item loops without caching.

#### 5. `json.Marshal` vs `json.Encoder`

- Response: `json.NewEncoder(w).Encode(v)` — streaming, no intermediate buffer.
- Avoid `json.Marshal` for response bodies.

#### 6. `sync.Pool` for Temporary Objects

```go
var skeletonPool = sync.Pool{
    New: func() any { return &skeletonItem{} },
}
item := skeletonPool.Get().(*skeletonItem)
defer skeletonPool.Put(item)
```

#### 7. GC Tuning

DO NOT add `debug.SetGCPercent()` without discussion. Reduce allocation rate (points 1-6).
Use `pprof` or `trace` if there are complaints.

#### 8. Rate Limiter

The map must be bounded: evict oldest entries when unique IP limit is exceeded.

#### Checklist Summary

| # | Item | Required? |
|---|---|---|
| 1 | Repository has max-size limit | ✅ REQUIRED |
| 2 | TTL/expiry or cleanup goroutine present | ✅ REQUIRED |
| 3 | `List()` uses pagination (limit/offset) | ✅ REQUIRED |
| 4 | Template parsing cached (not per-request) | ✅ REQUIRED |
| 5 | `json.NewEncoder` instead of `json.Marshal` for responses | ✅ REQUIRED |
| 6 | Reflection minimized — use interface | ✅ REQUIRED |
| 7 | `sync.Pool` for hot path objects (if needed) | ⚠️ Recommended |
| 8 | `List()` pre-allocates capacity | ✅ REQUIRED |
| 9 | No unbounded maps without eviction | ✅ REQUIRED |

## Task Logging (REQUIRED)

### When starting a task
If not yet logged in `.github/tasks/queue.md`:
1. Read `queue.md`.
2. Add row: `| <PRIO> | <task-name> | User | $(date +%F) | in_progress |`
3. Update `session/current.md`.

### At checkpoint
P0/P1 >10 steps → call `checkpoint.prompt.md`.

### When done
1. Update `queue.md` to `in_review`.
2. After review passes → report to user.

## Completion Workflow

1. Implement per spec.
2. `go build ./... && go test ./...` — all green.
3. Build FE bundle (via `make build-fe` or esbuild command).
4. Call `@reviewer` with implementation summary.
5. If reviewer finds errors → fix → E2E validation (see below) → loop to step 2.
6. Only report done after reviewer approves.

### End-to-End Validation (REQUIRED after error feedback from Reviewer)

If the reviewer finds errors, after fixing you MUST:

1. **Backend:** `go build ./... && go test ./...` — all green.
2. **Frontend build:** `make build-fe` (or esbuild directly).
3. **Start server:** `go run .` (or `make dev`), ensure no panic.
4. **Browser validation:**
   - Open the module page in the browser.
   - Check **Console** — 404, 500, TypeError, SyntaxError, JS error = FAIL.
   - Test main flow: list, create, detail, delete.
   - Screenshot for visual verification.
5. If clean → report done. If still errors → fix and loop.

> Do not skip browser validation. Runtime JS errors, MIME mismatches, 404 assets
> are only detected via browser console.

### Fast-track (skip E2E for minor changes)

If only typo, minor field rename, comments:
- `go build ./...` + `go test ./...`
- Build FE bundle
- Skip browser test.

If touching runtime (handler, template, API response, esbuild config) → **E2E REQUIRED**.

## Best Practices

- **Use `scaffold.sh`** — do not write boilerplate manually.
- **Latest template model:** `title`/`content`/`author`, not `name`/`status`.
- **Do not modify `register.go` manually** — scaffold handles auto-registration.
- **Test before reporting:** `go test ./modules/<feature>/...` and `npx vitest run modules/<feature>/`.

If a requested change genuinely requires crossing a module boundary or touching `core/`,
say so explicitly and explain why, rather than silently working around the rule.
