---
agent: 'ask'
description: 'Explain one feature module end-to-end, backend to frontend'
---

Explain the module `${input:module:Which module (folder name under modules/)?}` end-to-end,
in the order a request actually flows:

1. **Entry route** — what route(s) `module.go` registers, and to which handler.
2. **Handler** — what `handler.go` does with the request (validation, response shape).
3. **Service** — what business logic lives in `service.go`.
4. **Repository** — what data access `repository.go` does, and what storage it touches.
5. **Model** — the domain type(s) in `model.go` and where they're used.
6. **Frontend** — how `<Feature>.tsx` renders, what it calls in `api.ts`, and which routes
   from step 1 those calls hit.
7. **Local components** — anything in this module's `components/` folder and where it's used.

Also note, if relevant:
- Anything this module imports from `core/` (shared infra) and why.
- Anything in root `components/` this module's frontend uses (shared UI).
- Any place the module's boundaries look blurry (e.g. logic that arguably belongs in
  `service.go` but currently lives in `handler.go`).

Keep the explanation grounded in the actual code — quote function/file names, don't
paraphrase generically. If a file listed above (e.g. no local `components/`) doesn't exist
for this module, just say so instead of inventing one.
