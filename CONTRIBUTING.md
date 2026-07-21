# Contributing to Flow

First off, thanks for taking the time to contribute! 🎉

Flow is an AI-native framework — its conventions, agents, and skills are designed to be extended by both humans and AI. This document covers the human side.

## How to contribute

### 1. Fork & branch

```bash
git clone https://github.com/<your-username>/flow
cd flow
git checkout -b feat/my-feature
```

Branch naming:
- `feat/` — new features or modules
- `fix/` — bug fixes
- `docs/` — documentation
- `chore/` — tooling, config, CI

### 2. Set up

```bash
.github/skills/init-core-project/scripts/init-core.sh
go build ./...
```

### 3. Make your changes

- **New feature module?** Use the scaffold script — don't hand-write boilerplate:
  ```bash
  .github/skills/new-feature-module/scripts/scaffold.sh <name> [--ssr]
  ```
- **Bug fix?** Write a test first, then fix.
- **Agent/instruction changes?** See `agents/`, `prompts/`, `instructions/` in `.github/`.

### 4. Test

```bash
make test          # Go tests + Vitest
go build ./...     # Ensure everything compiles
npx vitest run     # Frontend tests (if you changed FE code)
```

All tests must pass before submitting a PR.

### 5. Commit

We squash all commits before merging, so don't worry about commit history. Just keep
messages clear:

```
feat: add billing module with Stripe integration
fix: correct MIME type for CSS files in cachedFileServer
docs: update architecture diagram
```

### 6. Submit a pull request

- Describe what you changed and why.
- If it fixes an issue, reference it: `Closes #123`.
- If it changes agent behavior, mention that.

## Code standards

### Go
- `gofmt` + `goimports`.
- Wrap errors with `%w`.
- Constructor DI, no global state.
- Table-driven tests.

### TypeScript / React
- Strict mode, no `any`.
- Functional components + hooks only.
- API calls go through `api.ts`, not raw `fetch()` in components.
- Tailwind CSS v4 classes only — no inline `style={{}}` except for dynamic values.

### Memory & GC (Go)
Every in-memory store **must** have:
- Max-size limit
- TTL/expiry or cleanup goroutine
- Pagination on `List()`

See `implementer-be.agent.md` for the full checklist.

## Need help?

Open a [discussion](https://github.com/ynwd/flow/discussions) or an issue.
