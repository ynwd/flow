---
name: db-migration
description: Create and run a database schema migration across every tenant database plus the global database in db/. Use this whenever the user asks to add/alter a table or column, or otherwise change schema — never hand-edit a single tenant DB directly.
---

# Database Migration (multi-tenant)

This repo has multiple tenant databases plus one global database under `db/`. A schema
change must be written once and applied to **every** database consistently — never patch one
tenant's DB by hand, since they will drift out of sync with each other and with `global.db`.

> Adjust the specifics below (`tools/migrate`, file naming, SQL dialect) to match how
> migrations actually work in this repo if they differ — this is the pattern, not a literal
> copy-paste for every project.

## When to use this

- Adding/removing a table or column.
- Changing a column type, constraint, or index.
- Any change that must be identical across all tenant DBs and `global.db`.

Do NOT use this for one-off data fixes in a single tenant — that's a manual, tenant-scoped
operation, not a schema migration.

## Workflow

1. **Write the migration once**, as a new versioned SQL file (or via whatever migration tool
   lives in `tools/migrate`), e.g. `db/migrations/<NNNN>_<description>.sql`. Never write raw
   `ALTER TABLE` directly against a specific tenant file.
2. **Decide scope**: does this change apply to tenant DBs only, `global.db` only, or both?
   Say so explicitly in the migration description/commit message — don't leave it implicit.
3. **Dry-run against one tenant DB first** (see script below with `--dry-run` or a single
   `--target`), inspect the result, then apply to all.
4. **Apply to every tenant DB + global.db** using the runner script — never loop manually
   with ad hoc SQL, since it's easy to skip one tenant silently.
5. **Verify**: after applying, confirm the schema version/checksum matches across every DB
   file in `db/`. If one is out of sync, stop and investigate before continuing — don't apply
   a second migration on top of a partially-applied one.

## Running the migration across all DBs

```bash
.github/skills/db-migration/scripts/run-migration.sh <migration-file>
```

- Applies the migration to every `*.db` file under `db/` (tenants + `global.db`), in order,
  stopping immediately on the first failure so DBs don't silently drift out of sync.
- Use `--dry-run` to preview which files it would touch without applying anything.
- Use `--target <name>` to apply to a single database file only, for the dry-run-on-one-
  tenant step above.

## After migrating

- Update the domain type(s) in the relevant module's `model.go` to match the new schema.
- Update `repository.go` queries in the affected module(s) accordingly.
- Add/update a test that exercises the new column/table via the repository layer, not just
  raw SQL.
