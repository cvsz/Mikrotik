# Codex Instructions for zOS

Read and follow `AGENTS.md` first. It is the canonical operating contract for this repository.

## Codex adapter rules

- Inspect repository state before editing and prefer the smallest reviewable change.
- Preserve zOS production safety gates: audit, backup, dry-run, recovery/Safe Mode where appropriate, explicit operator opt-in, and post-change verification.
- Do not turn normal CI into a live RouterOS control channel.
- Keep `core.zeaz.dev` as DEV/controller and `prod.zeaz.dev` as PROD.
- Treat `zOS-Runner` as a validation surface unless a workflow explicitly defines a safe operator-gated action.
- Keep imported RouterOS skill provenance and zOS safety adaptations intact.
- When changing analyzer/evaluator behavior, update the deterministic evidence corpus under `evidence/` and keep expected outputs reviewable.

## Required local checks

```bash
make validate
make evidence
```

If the change affects security evidence generation, also run:

```bash
make security-evidence
```
