# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in Flow, please report it privately.

**Do not open a public issue.** Instead, send a description of the issue to
the repository maintainers via GitHub's private vulnerability reporting at:

https://github.com/ynwd/flow/security/advisories

Alternatively, if that's not available, reach out directly to the maintainers
through a private channel.

We will acknowledge receipt within **48 hours** and provide a timeline for a fix.

## Scope

Security issues include, but are not limited to:

- Cross-module import violations that bypass tool restrictions
- In-memory store exhaustion (OOM via unbounded `Create()`)
- Rate-limiter bypass
- Same-origin policy bypass in middleware
- Exposure of secrets or credentials in templates or generated code

## Expectations

- You will receive a response within 48 hours.
- We will keep you informed of progress toward a fix.
- After a fix is released, we will publicly acknowledge the report (if desired).

## Supported Versions

| Version | Supported |
|---|---|
| main (latest) | ✅ |
| Older releases | ❌ |
