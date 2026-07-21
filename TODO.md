# TODO — Improvement Backlog

> Auto-generated dari codebase review (2026-07-25).
> Kerjakan satu per satu. Centang setelah selesai.

---

## 🔴 HIGH PRIORITY

- [x] **1. ~~Fix CI workflow~~** — ~~Downgrade GitHub Actions ke stable versions~~ **CLOSED (False Positive)**
  - Semua versi sudah latest stable. Upgrade minor: `setup-go@v6` → `@v7` ✅

- [x] **2. ~~Fix `.gitignore` module rules~~** — ~~Document atau pindah branch-specific~~ **FIXED**
  - File: `.gitignore` (L36-37)
  - ✅ Removed `modules/*` + `!modules/register.go` (mengabaikan semua module code)
  - ✅ Komentar Indonesia dihapus
  - ✅ Build artifacts tetap di-ignore: `modules/*/static/dist/`, `modules/*/package-lock.json`

- [x] **3. ~~Fix `SameOrigin` middleware~~** — ~~Pakai `url.Parse` bukan `strings.Contains`~~ **FIXED**
  - File: `.github/skills/init-core-project/templates/core/middlewares/sameorigin.go.tmpl`
  - ✅ Replaced `strings.Contains(origin, r.Host)` with `url.Parse` + exact hostname comparison
  - ✅ `evil-example.com` tidak bisa bypass `example.com` lagi

- [x] **4. ~~Fix `repository.go.tmpl`~~** — ~~Tambah Memory/GC protections~~ **FIXED**
  - File: `.github/skills/new-feature-module/repository.go.tmpl`
  - ✅ Added `maxItems = 10000` limit with `ErrStoreFull` error
  - ✅ Added `defaultTTL = 24h` with `itemWithTTL` wrapper struct
  - ✅ Added cleanup goroutine (every 5 min) + `Stop()` for graceful shutdown
  - ✅ Added pagination: `List(ctx, limit, offset)` with default limit=50
  - ✅ Updated `handler.go.tmpl` — query params `?limit=&offset=` + 503 for store full
  - ✅ Updated `service.go.tmpl` — interface + method signature
  - ✅ Updated `handler_test.go.tmpl` + `service_test.go.tmpl` — fake repos + tests

---

## 🟡 MEDIUM PRIORITY

- [x] **5. ~~Tambah Makefile targets~~** — ~~`dev` dan `build-fe`~~ **CLEANED**
  - ✅ Removed ghost targets from `.PHONY`: `dev`, `build`, `build-fe`
  - ✅ Removed references from `build-and-git.md`
  - ✅ `run` sudah cover BE + FE

- [x] **6. ~~Cache landing page template~~** — ~~Parse sekali di init, bukan per-request~~ **FIXED**
  - File: `.github/skills/init-core-project/templates/core/router/router.go.tmpl`
  - ✅ `landingTemplate` parsed once at package init via `template.Must(template.ParseFS(...))`
  - ✅ Removed per-request `template.ParseFS()` from handler

- [x] **7. ~~RateLimiter tambah max-IP limit~~** — ~~Evict oldest IPs when exceeded~~ **FIXED**
  - File: `.github/skills/init-core-project/templates/core/middlewares/ratelimit.go.tmpl`
  - ✅ Added `maxIPs = 50000` limit
  - ✅ Added `evictOldest()` method — removes IP with oldest request when limit hit
  - ✅ Eviction triggers only for NEW IPs (not existing ones hitting rate limit)

- [x] **8. ~~Render.go kurangi reflection~~** — ~~Cache `reflect.Type`, hapus JSON round-trip~~ **FIXED**
  - File: `.github/skills/init-core-project/templates/core/templates/render.go.tmpl`
  - ✅ Added `typeCache sync.Map` + `getOrCacheTypeInfo()` — cache `reflect.Type` metadata
  - ✅ Added `typeInfo`/`fieldInfo` structs — store field indices, keys, flags per type
  - ✅ `renderSkeleton()` checks `SSRData` interface first — zero reflection if implemented
  - ✅ Removed `json.Marshal`/`json.Unmarshal` round-trip — uses `fmt.Sprintf` fallback

---

## 🟢 NICE TO HAVE

- [x] **9. ~~Tambah test router~~** — **FIXED**
  - ✅ Created `router_test.go.tmpl` — tests for RegisterModule, GetModules, BuildRouter, cachedFileServer

- [x] **10. ~~Tambah test render~~** — **FIXED**
  - ✅ Created `render_test.go.tmpl` — tests for structToMap, getStr, truncate, formatDate

- [x] **11. ~~Tambah test ulid~~** — **FIXED**
  - ✅ Created `ulid_test.go.tmpl` — tests for New(), uniqueness, non-empty

- [x] **12. ~~Tambah eslint.config.js~~** — **EXISTS** (already in templates)
  - ✅ `eslint.config.js.tmpl` already existed with proper ESLint v9 flat config

- [x] **13. ~~Tambah tsconfig.json~~** — **FIXED**
  - ✅ Created `tsconfig.json.tmpl` — strict mode, ES2022, react-jsx, noUncheckedIndexedAccess

- [x] **14. ~~Normalisasi bahasa~~** — **FIXED**
  - ✅ Fixed Indonesian in `init-core.sh` (4 comments)
  - ✅ Fixed Indonesian in `clean-root.sh` (1 comment)
  - ✅ Fixed Indonesian in `scaffold.sh` (2 messages)
  - ✅ Fixed `Deteksi` → `Detection` in `task-orchestration.md`

- [x] **15. ~~Fix typo~~** — **FIXED**
  - ✅ Removed duplicate "new module" in `copilot-instructions.md` L42
