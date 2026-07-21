# Build, Test & Validate

## Make Commands (preferred)

```bash
make run         # Build CSS + all FE bundles + start server
make dev         # Go server only (hot-reload)
make build       # Build Go binary → bin/flow
make build-fe    # Build single module: make build-fe name=blog
make test        # Go tests + vitest
make lint        # golangci-lint + eslint
make clean       # Remove all generated files
make help        # List all commands
```

## Manual Commands

```bash
go build ./... && go test ./... && go vet ./...         # Backend
golangci-lint run ./...                                  # Lint backend

# Frontend (npm workspaces)
npm install
npm run build -w modules/<feature>                       # Build module
npm run watch -w modules/<feature>                       # Dev mode

npx eslint 'modules/**/*.{ts,tsx}'                       # Lint frontend
npx vitest run                                           # Test frontend
```

## Git Workflow

- `main` = production-ready. All changes go through feature branches.
- Branch naming: `feat/<feature>`, `fix/<description>`, `chore/<description>`.
