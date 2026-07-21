---
agent: 'agent'
description: 'Add a new HTTP endpoint + matching FE call to an existing feature module'
---

Add a new endpoint to an **existing** module (do not create a new module — if the feature
doesn't exist yet under `modules/`, use the `new-feature-module` skill instead).

Ask for these if not provided via `${input:module:Which module (folder name under modules/)?}`
and `${input:route:What route/method, e.g. "POST /billing/invoice"}`:

1. Which module (folder name under `modules/`).
2. The route path and HTTP method.
3. What it does, in one sentence.

Then:

1. Add the handler function to that module's `handler.go`, following the existing pattern in
   the file (same error handling / response shape as the other handlers there).
2. Add the corresponding method to `service.go`, and to `repository.go` if it needs data
   access — do not put business logic directly in the handler.
3. Register the new route in that module's `module.go`, next to the existing routes — do not
   create a second registration function.
4. Add a matching typed function to that module's `api.ts` frontend client, following the
   existing fetch/error pattern in that file. Do not add a raw `fetch()` call anywhere else.
5. If a component needs to use it, wire it into the existing `<Feature>.tsx` or a file under
   that module's `components/` — not into root `components/`.
6. Add tests for the new endpoint:
   - **Backend:** update `handler_test.go` and `service_test.go` with new test cases.
   - **Frontend:** update `api.test.ts` with a test for the new API function, and
     `<Feature>.test.tsx` if the component behavior changed.

Keep the change scoped to this one module. If implementing this endpoint would require
reaching into another module's internals, stop and report that instead of importing across
the boundary — see [copilot-instructions.md](../copilot-instructions.md) module boundary
rules.
