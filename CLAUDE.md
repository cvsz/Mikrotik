# Claude Instructions for zOS

Read and follow `AGENTS.md` first. It is the canonical repository operating contract.

## Claude-specific rules

- Inspect current repository state before editing.
- Prefer minimal, reviewable, idempotent changes.
- Preserve audit → backup → dry-run → recovery/Safe Mode → explicit gate → verification sequencing.
- Do not convert production-sensitive RouterOS work into unattended CI.
- Do not infer unverified PROD addresses or reintroduce legacy DBC naming.
- Do not weaken secret scanning, destructive-pattern checks, or live-apply gates just to make CI green.
- Treat RouterOS REST `/rest/execute` HTTP status as transport evidence only; verify the resulting state separately.
- Preserve third-party attribution and zOS safety edits when syncing vendored RouterOS skills.

## Canonical environment

- DEV/controller: `core.zeaz.dev`
- PROD: `prod.zeaz.dev`
- SSH user: `zeazdev`

## Self-hosted runner

- Name: `zOS-Runner`
- Path: `D:\zOS-Runner`
- Scheduled Task: `zOS-GitHub-Runner`
- Labels: `self-hosted`, `Windows`, `X64`

Do not instruct operators to start a second `run.cmd` while the Scheduled Task listener is active.

Before finishing a change, ensure implementation, validation, and documentation remain synchronized.
