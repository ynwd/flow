# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

- Nothing yet.

## [v0.0.3] - 2026-07-25

- Fix landing page layout and CI optimization ([4841e7a](https://github.com/ynwd/flow/commit/4841e7a))

## [v0.0.2] - 2026-07-25

- Fix `make run` error — handle `fuser` exit code in Makefile ([9e39c8f](https://github.com/ynwd/flow/commit/9e39c8f))
- Add release skill with auto-version detection ([81d318f](https://github.com/ynwd/flow/commit/81d318f))
- Upgrade `action-gh-release@v2` → `@v3` for Node.js 24 ([7cff390](https://github.com/ynwd/flow/commit/7cff390))

## [v0.0.1] - 2026-07-25

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
