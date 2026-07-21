---
name: squash-commits
description: Squash all commits on the active branch into 1 commit.
---

# Squash Commits Skill

## When to use this

Use this skill when:
- **Too many small commits** — branch history is full of "fix typo", "wip", "lint", etc.
- **Want to push a clean PR** — before pushing feature branch, squash into 1 commit.
- **Duplicate commits exist** — after `git reset --soft` or rebase, history needs cleanup.
- **Want to merge to main** — easier to review when there is only 1 commit per feature.

DO NOT use for:
- Squashing commits on `main` branch that has already been pushed (requires force push).
- Deleting files or code.

## How It Works

The `squash-commits.sh` script will:

1. Detect the active branch and current commit count.
2. Find the root commit (first commit without parent).
3. `git reset --soft` to root commit — stage all changes.
4. Re-commit with a new message you specify.
5. Display force push instructions.

## How to Run

### Agent Flow (Recommended)

The agent should **prompt the user** via `vscode_askQuestions` BEFORE running the script:

```json
{
  "questions": [
    {
      "header": "squash-confirm",
      "question": "Squash all commits into 1?",
      "options": [
        { "label": "Yes, squash and push", "recommended": true },
        { "label": "Yes, squash only (no push)" },
        { "label": "Cancel" }
      ]
    }
  ]
}
```

Then run the script with the appropriate flag:
- **Squash + Push**: `squash-commits.sh --push "message"`
- **Squash only**: `squash-commits.sh --no-push "message"`

### CLI Usage

```bash
.github/skills/squash-commits/scripts/squash-commits.sh [--push|--no-push] "Pesan commit"
```

**Options:**
- `--push` — Push to remote after squash (no terminal prompt)
- `--no-push` — Skip push after squash (no terminal prompt)
- *(no flag)* — Outputs `NEEDS_PUSH=true` for agent to handle

### Example

```bash
# Squash with push
.github/skills/squash-commits/scripts/squash-commits.sh --push "feat: add billing module"

# Squash without push
.github/skills/squash-commits/scripts/squash-commits.sh --no-push "Initial commit"
```

## After Squash

The script only modifies the local branch. To push to remote:

```bash
git push --force-with-lease origin <branch>
```

> ⚠️ **Be careful with force push** — only do this if the branch belongs to you
> and no other collaborators are working on it.

## Integration

This skill is a **partner** to the git workflow:

```
feature branch (many commits)
  → squash-commits (1 clean commit)
  → push --force-with-lease
  → create PR / merge
```
