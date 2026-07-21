---
agent: 'agent'
description: 'Review a diff/PR against this repo module-boundary rules'
---

Review the current changes (`${selection}` if a specific range is selected, otherwise the
working tree diff) against the architecture rules in
[copilot-instructions.md](../copilot-instructions.md).

Check specifically for:

1. **Module boundary violations** — any file in `modules/<feature-a>/` importing directly
   from `modules/<feature-b>/`'s Go package or TS files. Flag it even if it "would work".
2. **Misplaced shared code** — a component added to root `components/` or logic added to
   `core/` that is actually only used by one feature. It should live inside that feature's
   `modules/<feature>/` folder instead.
3. **New modules that skip the standard shape** — a new `modules/<feature>/` folder missing
   `module.go` (route registration) or mixing multiple unrelated features into one folder.
4. **Frontend calling the backend directly** — any `.tsx`/`.ts` file outside `api.ts` calling
   `fetch()` against this feature's own route. All calls should go through that feature's
   `api.ts`.
5. **Go conventions** — unwrapped errors (missing `%w`), global state instead of constructor
   injection, missing table-driven tests for new logic.
6. **Frontend conventions** — `any` types, class components, missing prop types.

Output format:

- Group findings by severity: **Must fix** (breaks module boundary rules) vs **Suggestion**
  (style/convention).
- For each finding: file path, one-line explanation, and a concrete fix — not just "this is
  wrong".
- If nothing violates the rules, say so explicitly rather than inventing nitpicks.
