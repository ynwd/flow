---
name: feature-spec
description: Produce a feature specification document in .github/specs/<feature>.md. Run this when a new feature request needs analysis before implementation.
---

# Feature Spec Skill

This skill is triggered when the `analyst` agent (or any agent) needs to produce a
structured feature specification before implementation begins.

## When to use

- A user requests a new feature/module
- The request needs clarification before coding
- Before scaffolding a new module with `new-feature-module` skill

## How to use

The `analyst` agent will ask clarifying questions (if needed), then write the spec to
`.github/specs/<feature>.md` using the template below.

### Mandatory Questions — ALL must be asked to the user

You MUST use the **`vscode_askQuestions`** tool to ask questions — do NOT write
questions as plain chat text. Users only see questions when they appear
as a popup dialog.

> ⚠️ **IMPORTANT — Batch System:**
> Do NOT ask all questions in a single batch! `vscode_askQuestions` is limited to ~4 questions
> per call. Split into **3-4 separate batches**:
> - **Batch 1**: Wireframe + Entity fields + Status lifecycle
> - **Batch 2**: Layers + SSR + Access per endpoint
> - **Batch 3**: Validation + List pagination/filter (H1)
> - **Batch 4** (complex only): Create fields (H2) + Update strategy (H3) + Delete strategy (H4) + Response format (H5)
>
> Wait for the user's answer on each batch before moving to the next.
> Do not proceed to the next batch before the user answers the previous one.

| # | Pertanyaan | Batch | Opsi / Format |
|---|---|---|---|
| 1 | **Wireframe/UI Design?** | Batch 1 | Default template / Custom (upload image) |
| 2 | **Entity fields?** | Batch 1 | Default (title, content, author) or additional |
| 3 | **Status lifecycle?** | Batch 1 | Not needed / Yes (specify transitions) |
| 4 | **Layers?** | Batch 2 | Fullstack (h s r m p f) / Backend only (h s r m) / Frontend only (h p f) |
| 5 | **SSR?** | Batch 2 | Yes / No |
| 6 | **Access per endpoint?** | Batch 2 | All public / Custom per-endpoint |
| 7 | **Validation?** | Batch 3 | Default (title + content required) or additional |
| 8 | **Routes detail?** | — | — |
|    | H1. List pagination/filter/sorting? | Batch 3 | No pagination / Yes limit-offset / Has filter |
|    | H2. Create fields? | Batch 4* | Default (title, content, author) or additional |
|    | H3. Update strategy? | Batch 4* | PUT full replace / PATCH partial |
|    | H4. Delete strategy? | Batch 4* | Hard delete / Soft delete |
|    | H5. Response format? | Batch 4* | Direct data / Wrapped { data } |

> **IMPORTANT:** Batch 4 (H2-H5) can be skipped for standard CRUD (Batch 1-3 is sufficient).
> Only ask Batch 4 if the entity has unique fields or special logic.
> For standard CRUD like blog/todo/billing, Batch 1-3 is sufficient.

## Spec Template

```markdown
# Feature: <name>

## Description
<!--- One paragraph. -->

## Entity
- `<Entity>` { id, field1, field2, ... }
- Status: `pending` → `active` | `cancelled`

## Layers
- [ ] handler (h)
- [ ] service (s)
- [ ] repository (r)
- [ ] model (m)
- [ ] page (p)
- [ ] frontend (f)

## Routes
| Method | Path | Access | Request Body | Notes |
|---|---|---|---|---|
| GET | /<feature> | public | — | SSR page |
| POST | /api/<feature> | same_origin | JSON fields | — |
| GET | /api/<feature> | same_origin | — | Pagination? |
| GET | /api/<feature>/{id} | same_origin | — | — |
| PUT | /api/<feature>/{id} | same_origin | JSON fields | Full or partial? |
| DELETE | /api/<feature>/{id} | private | — | Soft or hard? |

> Access can vary per endpoint. Default: GET public, POST/PUT same_origin, DELETE private.

## Validation
- field1 is required
- field2 must be unique

## UI Design
<!---
If the user provides a sketch/wireframe/UI image, the analyst MUST analyze it
and write a detailed description here. If the user does not provide a sketch, write:
"Default template — scaffold will generate standard UI."
-->

### Layout
<!--- Page layout description: header, sidebar, main content, footer, grid, etc. -->

### Pages / Views
<!--- List of pages and their main components:
- List page: table/cards, add button, search bar, filter
- Detail page: info panel, edit/delete buttons
- Form page: input fields, dropdown, submit button
-->

### States
<!--- Loading, empty, error, success — how each state is displayed. -->

### Components
<!--- React components to create (for this page only, not shared). -->
- [ ] Can create
- [ ] Can list
- [ ] Can update status
- [ ] Can delete
```

## UI Sketch Flow

When the analyst asks the user, the analyst MUST offer the option to send a sketch:

1. Ask: "Do you have a sketch/wireframe to attach? (send image)"
2. If **yes**: analyst receives the image → analyzes layout, components, states →
   writes detailed description in the **UI Design** section of the spec.
3. If **no**: spec just writes "Default template — scaffold will generate standard UI."
   in the UI Design section. Implementer will use the default scaffold template.

### How the analyst analyzes a sketch

When the user sends a sketch image, the analyst must:

1. **Use the `view_image` tool** to view the image.
2. Identify:
   - **Layout structure**: header, main, sidebar, footer, grid system
   - **Components per page**: cards, tables, forms, buttons, navigation
   - **States**: loading, empty, error, success — how they look
   - **Page anatomy**: list page, detail page, form page, etc.
3. Write description to the **UI Design** section in the spec — detailed enough that
   the `implementer` can reproduce the layout without seeing the original image.

> Analyst only analyzes the sketch. No need to worry about specific font/color —
> theme is handled by Tailwind CSS variables (`app.css`).
> Focus on layout, components, and states.
