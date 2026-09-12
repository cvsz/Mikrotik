# Contributing to zOS

zOS is production-sensitive infrastructure automation. Optimize changes for recoverability, idempotence, and evidence.

## Development flow

1. Create a focused branch from current `main`.
2. Keep changes small and reviewable.
3. Update documentation when behavior or operational assumptions change.
4. Run validation locally.
5. Open a pull request and require CI to pass before merge.

## Required validation

```bash
make validate
./zOS/bin/zos help
```

When relevant, also run read-only checks:

```bash
make core-status
make core-check
make status
make audit
make verify
```

Normal CI must not apply live RouterOS configuration.

## RouterOS change rules

- Audit before mutation.
- Back up before mutation.
- Dry-run imports before live apply.
- Use Safe Mode or another verified recovery path for risky production changes.
- Require explicit operator opt-in.
- Prefer stable selectors such as names/comments or looked-up IDs.
- Preserve management access.
- Verify effects independently after change.

## Secrets and sensitive material

Never commit passwords, access tokens, SSH/WireGuard private keys, GitHub runner credentials, RouterOS binary backups, sensitive production exports, or local `.env` files.

## Documentation

Behavior-changing PRs should update the relevant subset of:
`README.md`, `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `ENVIRONMENTS.md`, `CHECKLIST.md`, `SECURITY.md`, `docs/RUNBOOK.md`, `docs/DISASTER-RECOVERY.md`, `docs/SELF_HOSTED_RUNNER.md`, and `docs/zOS.md`.

## Pull request checklist

- [ ] Change is scoped and idempotent where practical.
- [ ] No secrets or sensitive backups are committed.
- [ ] Production mutation paths remain fail-closed.
- [ ] Tests/static validation pass.
- [ ] Documentation matches implementation.
- [ ] DEV/PROD naming remains canonical.
- [ ] Recovery implications are documented.
