---
name: add-shared-component
description: Decide whether a React component belongs in the shared root components/ folder or should stay local to a single module, and move it correctly if promoting. Use this whenever the user asks to "share" a component across features, move something to shared components, or asks where a new component should live.
---

# Add / Promote a Shared Component

This repo defaults components to living inside `modules/<feature>/components/`. Root
`components/` is only for components genuinely used by **two or more modules**. This skill
exists so that decision is made consistently instead of ad hoc.

## Decision checklist

Before moving or creating anything in root `components/`, confirm ALL of these:

1. **Actually used by ≥2 modules right now** — not "might be reused later". Speculative
   sharing is the default failure mode this skill exists to prevent; if there's only one
   consumer today, it stays local.
2. **No feature-specific logic or copy baked in** — e.g. it must not hardcode a feature's
   route, a feature-specific label, or import that feature's `api.ts` types. If it does,
   generalize it first (props instead of hardcoded values) as part of the move.
3. **Styling is generic** — if the visual design is tied to one feature's specific context
   (e.g. `ClaimLocationCard` styled only for the location flow), it likely isn't a true shared
   component yet, even if visually similar components exist in two modules. Two similar-
   looking cards are not automatically one shared component — check if they're expected to
   evolve together or diverge.

If any of these fail, the component stays in `modules/<feature>/components/`, even if a
second module could copy-paste it for now.

## How to promote a component

1. Move the file from `modules/<feature>/components/X.tsx` to `components/X.tsx`.
2. Update its imports: remove any feature-specific type/util imports; replace with props.
3. Update every importer (the original module, and the new consumer(s)) to import from the
   new root path.
4. Add/adjust a TypeScript prop interface so the component has no implicit dependency on any
   one module's data shape.
5. If the component had feature-specific tests, keep feature-specific test cases in each
   consuming module, but add one general test alongside the component itself in
   `components/`.

## How to demote a component back to local

If a "shared" component in root `components/` ends up only used by one module again (the
other consumer was removed or diverged), move it back into that module's `components/`
folder and drop the generalized props back to whatever that module actually needs. Don't
leave single-consumer components in root "just in case."
