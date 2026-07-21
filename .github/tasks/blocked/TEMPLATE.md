# Blocker Template

Use this template when writing blocker files to `.github/tasks/blocked/<task>.md`.

```markdown
# Blocked: <Task Name>

## Task Description
<!--- Description of the failed task. -->

## Error / Failure Reason
<!--- Root cause error, stack trace, or brief log. -->

## Attempt Log

| Attempt | What happened | Agent |
|---|---|---|
| 1 | <summary> | @implementer |
| 2 | <summary> | @implementer |
| 3 | <summary> | @reviewer → @implementer |

## Recommended Next Action
<!--- What needs to be done to unblock this task. -->
```

## Example

```markdown
# Blocked: Add Payment Module

## Task Description
Create a payment module with Stripe integration.

## Error / Failure Reason
`go build` failed because the `stripe` package was not found in `go.mod`.

## Attempt Log

| Attempt | What happened | Agent |
|---|---|---|
| 1 | Scaffold succeeded, but `go build` failed — missing stripe dependency | @implementer |
| 2 | Added `go get stripe`, but version incompatible with Go 1.24 | @implementer |
| 3 | Reviewer analyzed, found that stripe SDK requires Go 1.21 | @reviewer |

## Recommended Next Action
Use Stripe REST API directly (without SDK). Remove stripe dependency from go.mod.
```
