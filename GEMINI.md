# Gemini Instructions for zOS

Use `AGENTS.md` as the canonical repository policy and safety contract.

## Gemini-specific rules

- Ground recommendations in the current repository state before proposing edits.
- Preserve canonical environment naming: `core.zeaz.dev` = DEV/controller, `prod.zeaz.dev` = PROD.
- Prefer deterministic and idempotent RouterOS changes.
- Never bypass backup, dry-run, explicit live-change gating, recovery access, or post-change verification.
- Never introduce real credentials, private keys, production identifiers, or sensitive backups into generated files.
- Never assume an HTTP 200 from RouterOS `/rest/execute` proves the command succeeded.
- Keep normal CI validation-only unless an action is explicitly safe and operator-gated.
- Preserve third-party attribution for vendored RouterOS skills.

## Runner

The Windows x64 runner is `zOS-Runner`, installed under `D:\zOS-Runner` and managed by Scheduled Task `zOS-GitHub-Runner`. GitHub Actions scheduling uses labels `self-hosted`, `Windows`, `X64`.

If architecture, topology, runner operation, RouterOS phases, CLI behavior, or safety policy changes, update the related docs in the same PR.
