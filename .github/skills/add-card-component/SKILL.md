---
name: add-card-component
description: Create or update the shared Card component (Card, Card.Header, Card.Content, Card.Footer) with dark/light theme support, progress bar, and step navigation. Use this whenever the user asks to add/update a Card component, modal card, wizard card, or step-based form container.
---

# Add Card Component

This skill creates a **flexible, reusable Card component** with sub-components
(Card.Header, Card.Content, Card.Footer) that supports:

- **Dark/Light theme** via Tailwind CSS `dark:` variants
- **Progress bar** in header (shows step progress)
- **Step navigation** with centered counter (1/3, 2/3, etc.)
- **Flexible content** — accepts any child components (forms, images, videos, text, etc.)

## When to use

Use this skill when:
- User asks to create a Card component
- User asks for a modal/wizard/step-based form container
- User asks for a flexible container component with header/content/footer
- User asks to update the existing Card component

Do NOT use for:
- Feature-specific cards (e.g., `ClaimLocationCard`) — those stay in `modules/<feature>/components/`
- Simple layout cards without header/footer structure

## How to run

### Install Card component

```bash
.github/skills/add-card-component/scripts/install-card.sh
```

Run from the repo root. The script will:
1. Check if `components/Card/` already exists (skip if exists, use `--force` to overwrite)
2. Copy all `.tmpl` templates from `.github/skills/add-card-component/templates/`
3. Remove `.tmpl` extension and place in `components/Card/`

### Template files

```
.github/skills/add-card-component/templates/
  components/
    Card/
      Card.tsx.tmpl           # Main container + sub-components
      Card.types.ts.tmpl      # TypeScript interfaces
      Card.test.tsx.tmpl      # Unit tests
      index.ts.tmpl           # Barrel export
```

### Installed files

```
components/
  Card/
    Card.tsx           # Main container + sub-components
    Card.types.ts      # TypeScript interfaces
    Card.test.tsx      # Unit tests
    index.ts           # Barrel export
```

## Component API

### `<Card>` — Main Container

```tsx
<Card 
  variant="modal"    // 'default' | 'modal' | 'panel'
  className="..."    // Optional custom classes
>
  {/* Children */}
</Card>
```

### `<Card.Header>` — Title Bar with Progress

```tsx
<Card.Header 
  title="Isi username & Password"
  onClose={() => {}}
  progress={{ current: 1, total: 3 }}  // Optional - hides bar if omitted
/>
```

**Progress Bar Rules:**
- `total = 1` → No progress bar displayed
- `total > 1` → Show N segments, current segment highlighted

### `<Card.Content>` — Flexible Content Area

```tsx
<Card.Content 
  padding="md"      // 'none' | 'sm' | 'md' | 'lg'
  scrollable={false}
>
  {/* Any children: forms, images, videos, text, etc. */}
</Card.Content>
```

### `<Card.Footer>` — Navigation with Centered Counter

```tsx
<Card.Footer
  prevButton={{ label: "Prev", onClick: handlePrev }}
  nextButton={{ label: "Next", onClick: handleNext }}
  stepIndicator={{ current: 2, total: 3 }}  // Shows "2/3" centered
/>
```

**Counter position:** Centered between Prev and Next buttons.

## Theme Support

The component uses Tailwind CSS dark mode with `dark:` variants:

| Element | Light Mode | Dark Mode |
|---------|-----------|-----------|
| Card bg | `bg-white` | `dark:bg-gray-900` |
| Card border | `border-gray-200` | `dark:border-gray-700` |
| Text | `text-gray-900` | `dark:text-gray-100` |
| Muted text | `text-gray-500` | `dark:text-gray-400` |
| Progress active | `bg-blue-600` | `dark:bg-blue-500` |
| Progress inactive | `bg-gray-200` | `dark:bg-gray-700` |
| Button primary | `bg-blue-600 text-white` | `dark:bg-blue-500` |
| Button secondary | `bg-gray-100` | `dark:bg-gray-800` |

**Dark mode activation:** Uses Tailwind's `class` strategy — add `dark` class to `<html>` to enable dark mode.

## Implementation Steps

1. Run `.github/skills/add-card-component/scripts/install-card.sh` to copy templates
2. Verify files are created at `components/Card/`
3. Run `npm run build -w components/Card` to verify (if workspace configured)
4. Run `npm test` to verify no regressions

## Example Usage (reconstructed from screenshots)

```tsx
// Step 1 of 3
<Card variant="modal">
  <Card.Header 
    title="Isi username & Password" 
    onClose={handleClose}
    progress={{ current: 1, total: 3 }}
  />
  <Card.Content>
    <Input label="User Name" placeholder="contoh: john-smith" helperText="Isi dengan alphabetic" />
    <Input label="Password" type="password" placeholder="contoh: john-smith" helperText="Minimal 8 karakter" />
  </Card.Content>
  <Card.Footer
    stepIndicator={{ current: 1, total: 3 }}
    nextButton={{ label: "Next", onClick: goToNext }}
  />
</Card>

// Step 2 of 3
<Card variant="modal">
  <Card.Header 
    title="Isi email dan whatsapp" 
    onClose={handleClose}
    progress={{ current: 2, total: 3 }}
  />
  <Card.Content>
    <Input label="Email" placeholder="john@gmail.com" helperText="Isi dengan email yang valid" />
    <Input label="Whatsapp" placeholder="contoh: john-smith" helperText="Isi dengan nomor hape yg valid" />
  </Card.Content>
  <Card.Footer
    prevButton={{ label: "Prev", onClick: goToPrev }}
    stepIndicator={{ current: 2, total: 3 }}
    nextButton={{ label: "Next", onClick: goToNext }}
  />
</Card>

// Step 3 of 3
<Card variant="modal">
  <Card.Header 
    title="Isi Alamat dan GPS" 
    onClose={handleClose}
    progress={{ current: 3, total: 3 }}
  />
  <Card.Content>
    <Input label="Alamat" defaultValue="Jl. Sultan Agung No.7..." helperText="Isi dengan alamat lengkap" />
    <div className="flex gap-4">
      <Input label="Latitude" placeholder="xxx" />
      <Input label="Longitude" placeholder="xxx" />
      <IconButton icon={<GPSIcon />} onClick={getGPSLocation} />
    </div>
  </Card.Content>
  <Card.Footer
    prevButton={{ label: "Prev", onClick: goToPrev }}
    stepIndicator={{ current: 3, total: 3 }}
    nextButton={{ label: "Save", onClick: handleSave }}
  />
</Card>

// Single step (no progress bar)
<Card variant="modal">
  <Card.Header 
    title="Konfirmasi" 
    onClose={handleClose}
    // progress omitted = no bar
  />
  <Card.Content>
    <p>Apakah kamu yakin?</p>
  </Card.Content>
  <Card.Footer
    nextButton={{ label: "Ya", onClick: confirm }}
  />
</Card>
```

## Integration with Existing Agents

- **@implementer-fe**: Can use this skill when implementing frontend components
- **@add-shared-component**: This component goes in root `components/` since it's generic
- **@feature-spec**: Can reference this skill when documenting UI components

## Validation

After implementation, verify:
1. [ ] TypeScript compiles without errors
2. [ ] Dark mode works by toggling `dark` class on `<html>`
3. [ ] Progress bar hides when `total = 1`
4. [ ] Progress bar shows correct segments when `total > 1`
5. [ ] Counter is centered between Prev/Next buttons
6. [ ] All sub-components accept `className` for customization
7. [ ] No inline styles or vanilla CSS — Tailwind only
