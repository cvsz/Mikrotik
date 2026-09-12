# dmux Instructions for zOS

Use `AGENTS.md` as the canonical operating contract for every pane, agent, or delegated task.

## dmux adapter rules

- Keep concurrent agents on isolated branches/worktrees and avoid editing the same file from multiple panes without coordination.
- Require each delegated task to preserve zOS production safety gates and documentation synchronization.
- Do not allow parallel agents to bypass CI, secret scanning, or review requirements to resolve conflicts faster.
- Merge evidence-bearing changes only after `make validate` and `make evidence` pass.
- Prefer deterministic corpus updates when changing analyzer, evaluator, PR salvage, discussion triage, or CI-diagnosis behavior.

## Compatibility checks

```bash
make validate
make evidence
```
