# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

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
