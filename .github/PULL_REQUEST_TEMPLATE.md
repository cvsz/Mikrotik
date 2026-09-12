## Summary

Describe what changes and why.

## Scope / risk

- [ ] Repository-only / no live system changed
- [ ] CORE/controller behavior
- [ ] RouterOS behavior
- [ ] GitHub Actions / runner / package behavior

Risk and blast radius:

## Validation

- [ ] `make validate`
- [ ] `make docs`
- [ ] `make evidence` when applicable
- [ ] `make security-evidence` when applicable
- [ ] Runtime checks when applicable

Paste only sanitized results or link CI runs.

## Production safety

- [ ] Management/recovery access is preserved
- [ ] Backup/dry-run requirements are addressed for live RouterOS work
- [ ] No secret/private key/runner credential/sensitive backup is committed
- [ ] Live mutation remains explicitly gated

## Documentation

- [ ] Relevant docs and `CHANGELOG.md` updated
- [ ] No documentation change required (explain why)

## Recovery / rollback

Describe rollback or explain why this is documentation/read-only only.

## Live impact

State explicitly whether any live CORE/router/PROD state was changed while preparing this PR.
