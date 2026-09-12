# Zed Agent Instructions for zOS

Read `AGENTS.md` first; it is the canonical repository operating contract.

## Zed adapter rules

- Prefer repository-local evidence and current files over inferred state.
- Keep live RouterOS changes outside ordinary editor automation and CI.
- Preserve DEV/PROD naming, zOS-Runner labels/path, and documented recovery gates.
- When editing skills or references, run the evidence/link validation so relative reference targets remain valid.
- Update corpus fixtures when changing behavior that affects ranking, classification, salvage, or troubleshooting decisions.

## Compatibility checks

```bash
make validate
make evidence
```
