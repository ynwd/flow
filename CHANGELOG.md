# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

- Nothing yet.

## [v0.1.0] - 2026-07-25

- simplify CHANGELOG update to use temp file approach (f97ed3c)
- simplify CHANGELOG update logic in release script (bf03b7d)
- auto-update CHANGELOG with categorized commit entries (561003e)
- update CHANGELOG for v0.0.1 (f637eca)
## [0.0.1] - 2026-07-25

### Added
- Initial open-source release.
- Go + React modular monolith scaffold (`init-core-project` + `new-feature-module`).
- AI agent orchestration: `@orchestrator`, `@analyst`, `@implementer-be`, `@implementer-fe`, `@reviewer`.
- Task queue with checkpoint/resume and self-healing error classification.
- SSR with skeleton HTML rendering (Go templates + React `createRoot`).
- In-memory CRUD store with `sync.RWMutex`, pagination, TTL, and max-size guard.
- Self-registration via `init()` + blank imports.
- Tailwind CSS v4 theming with dual light/dark mode.
- Webhook-to-task ingestion script.
- CI pipeline (Go build/test + FE build/test).
- End-to-end browser validation as part of completion workflow.
- Release skill with auto-version detection.
- GitHub Actions workflow for automated releases.

### Fixed
- CI workflow: reordered `init-core.sh` before `setup-go@v7` to fix cache restore.
- CI workflow: disabled Go module cache (`cache: false`) to resolve tar corruption.
- `.gitignore`: removed blanket `modules/*` rule that ignored all module code.
- `SameOrigin` middleware: replaced `strings.Contains` with `url.Parse` + exact hostname match (security fix).
- `repository.go.tmpl`: added `maxItems=10000`, `defaultTTL=24h`, cleanup goroutine (5 min), and paginated `List(limit, offset)`.
- `handler.go.tmpl`: updated to parse `?limit=&offset=` query params; returns `503` on `ErrStoreFull`.
- `service.go.tmpl`: updated interface to match paginated `List()` signature.
- `router.go.tmpl`: cached landing page template at package init (was parsing per-request).
- `ratelimit.go.tmpl`: added `maxIPs=50000` limit with `evictOldest()` to prevent OOM from multi-IP attacks.
- `render.go.tmpl`: added `sync.Map` type cache for `reflect.Type`; removed `json.Marshal`/`Unmarshal` round-trip; added `SSRData` interface fast-path.
- `render.go.tmpl`: fixed errcheck on `typeCache.Load()` type assertion.
- `router_test.go.tmpl`: fixed test URL paths.
- Makefile: removed ghost `.PHONY` targets (`dev`, `build`, `build-fe`).
- `build-and-git.md`: removed references to non-existent Makefile targets.
- `copilot-instructions.md`: fixed duplicate "new module" typo.
- `task-orchestration.md`: translated "Deteksi" → "Detection".
- Shell scripts: translated Indonesian comments to English.
- Release workflow: upgraded `action-gh-release@v2` → `@v3` for Node.js 24.

### Added (code review)
- `router_test.go.tmpl`: tests for `RegisterModule`, `GetModules`, `BuildRouter`, `cachedFileServer`.
- `render_test.go.tmpl`: tests for `structToMap`, `getStr`, `truncate`, `formatDate`, `SSRData` interface.
- `ulid_test.go.tmpl`: tests for `New()`, uniqueness, non-empty.
- `eslint.config.js.tmpl`: ESLint v9 flat config.
- `tsconfig.json.tmpl`: TypeScript strict mode config with `noUncheckedIndexedAccess`.
- CI workflow: upgraded `actions/setup-go@v6` → `@v7`.
- `README.md`: expanded with structured sections for SEO/AI crawlability.
