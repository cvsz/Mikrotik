# Codex Instructions for zOS

Read `AGENTS.md` first; it is the canonical contract.

Codex should inspect current repository state before editing, prefer focused reviewable diffs, preserve fail-closed production gates, and never infer live success from repository state alone.

## Completion checks

~~~bash
make validate
make docs
make evidence
~~~

Run `make security-evidence` when security-evidence behavior changes. Use runtime checks only when the task explicitly involves the live environment.

Documentation ownership and the project/vendored boundary are defined in `docs/INDEX.md`. GitHub workflow/release behavior is defined in `docs/GITHUB-OPERATIONS.md`.
