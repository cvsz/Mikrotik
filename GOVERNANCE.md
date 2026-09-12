# Governance

## Project ownership

`cvsz/zos` is currently maintained by the repository owner. Governance is intentionally lightweight but production-safety decisions are explicit and reviewable.

## Decision model

- Routine changes: normal pull request, required validation, maintainer review/merge.
- Production-sensitive changes: PR plus documented recovery/rollback implications and operator-gated live execution.
- Emergency runtime recovery: restore management/connectivity first, then back-port the durable fix through a reviewed PR.
- Security fixes: use the private reporting path when disclosure would expose a vulnerability or secret.

## Safety precedence

When convenience conflicts with recoverability, least privilege, verified topology, secret protection, or production availability, the safety constraint wins unless the repository owner explicitly approves a documented exception.

## Canonical sources

- Agent/automation policy: `AGENTS.md`.
- Environment inventory: `ENVIRONMENTS.md`.
- Documentation map: `docs/INDEX.md`.
- Production acceptance: `docs/PRODUCTION-READINESS.md`.
- Security policy: `SECURITY.md`.
- Contribution workflow: `CONTRIBUTING.md`.

## Change records

Notable behavior and operational changes belong in `CHANGELOG.md`. Architectural decisions that materially alter trust boundaries, topology, release policy, or production controls should be captured in durable documentation before or with implementation.

## Exceptions

Any exception to a fail-closed production gate should state scope, reason, owner, duration, rollback, and verification. Temporary recovery exceptions must be removed after the recovery objective is met.
