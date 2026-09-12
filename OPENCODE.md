# OpenCode Instructions for zOS

Use `AGENTS.md` as the canonical operating contract.

## OpenCode adapter rules

- Resolve repository state before proposing or applying edits.
- Keep production RouterOS work fail-closed and operator-gated.
- Do not invent PROD addresses, credentials, runner labels, or topology.
- Preserve documentation synchronization across README, runbooks, security policy, and harness contracts when behavior changes.
- Use `evidence/` fixtures to demonstrate analyzer, retrieval, PR salvage, triage, and CI-diagnosis behavior instead of relying on prose claims.
- Never embed real production secrets or raw sensitive logs in fixtures.

## Compatibility checks

```bash
make validate
make evidence
```
