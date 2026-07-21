.PHONY: init scaffold dev run css rebuild build build-fe test test-go test-fe lint lint-go lint-fe vet clean reset-tasks help

# ─── Init ───────────────────────────────────────────────
init:          ## Init core project from templates
	.github/skills/init-core-project/scripts/init-core.sh

# ─── Scaffold ────────────────────────────────────────────
scaffold:      ## Scaffold a new feature module: make scaffold name=blog [layers="h s r m p f"] [ssr=--ssr]
	@.github/skills/new-feature-module/scripts/scaffold.sh $(name) $(ssr) $(layers)


run:           ## Build all & restart Go server
	@fuser -k 3000/tcp 2>/dev/null
	@npm run build:css 2>&1 | tail -1
	@for dir in modules/*/; do \
		if [ -f "$$dir/package.json" ] && grep -q '"build"' "$$dir/package.json" 2>/dev/null; then \
			echo "→ Building $$(basename $$dir)..."; \
			npm run build -w "$${dir%/}" 2>&1 | tail -1; \
		fi; \
	done
	@go run . &

css:           ## Build Tailwind CSS
	npm run build:css

rebuild:       ## Copy app.css.tmpl → app.css, rebuild CSS, restart server
	@cp .github/skills/init-core-project/templates/core/static/css/app.css.tmpl core/static/css/app.css 2>/dev/null; npm run build:css 2>&1 | tail -1; fuser -k 3000/tcp 2>/dev/null; go run . &


# ─── Test ────────────────────────────────────────────────
test:          ## Run all tests (Go + Vitest)
	go test ./... -v
	npx vitest run

test-go:       ## Run Go tests only
	go test ./... -v

test-fe:       ## Run frontend tests only
	npx vitest run

# ─── Lint ────────────────────────────────────────────────
lint:          ## Run all linters
	golangci-lint run ./...
	npx eslint 'modules/**/*.{ts,tsx}'

lint-go:       ## Run Go linter only
	golangci-lint run ./...

lint-fe:       ## Run frontend linter only
	npx eslint 'modules/**/*.{ts,tsx}'

# ─── Vet ────────────────────────────────────────────────
vet:           ## Run go vet
	go vet ./...

# ─── Clean ──────────────────────────────────────────────
clean:         ## Remove all generated files (core, modules, node_modules)
	.github/skills/clean-root/scripts/clean-root.sh

reset-tasks:   ## Reset task queue & checkpoint
	.github/skills/reset-tasks/scripts/reset-tasks.sh

# ─── Help ────────────────────────────────────────────────
help:          ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'
