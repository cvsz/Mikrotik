# Evidence Matrix

zOS maintains reviewable evidence for automation behavior instead of relying on undocumented assumptions.

| Area | Evidence | Validation |
|---|---|---|
| Deep analyzer corpus | `evidence/corpus/analyzer/golden.jsonl` | schema, unique IDs, severity/code expectations |
| RAG/evaluator comparison | `evidence/corpus/rag/ranking.jsonl` | expected top-1 and ordered-prefix invariants |
| PR salvage/review corpus | `evidence/corpus/pr-salvage/cases.jsonl` | expected cleanup/salvage action vocabulary |
| Discussion triage corpus | `evidence/corpus/discussions/triage.jsonl` | expected informational/answered/no-response/actionable actions |
| Harness compatibility | `evidence/harness/compatibility.json` plus adapter docs | all required harness contracts exist and point to `AGENTS.md` |
| Security evidence | generated SPDX, SARIF, audit report | `tools/generate-security-evidence.py` |
| CI failure-mode evidence | `evidence/ci/failure-modes.jsonl` and `docs/CI-TROUBLESHOOTING.md` | signature/diagnosis/next-step validation |

## Commands

```bash
make evidence
make security-evidence
```

`make evidence` validates committed deterministic fixtures. `make security-evidence` generates ephemeral security artifacts under `artifacts/security/` and fails if high-confidence secret patterns are found in tracked source files.

## Evidence policy

- Fixtures must be synthetic or sanitized.
- Never commit real credentials, private keys, runner tokens, production exports, or sensitive incident payloads.
- A passing fixture set is regression evidence, not proof of production behavior outside the tested cases.
- Security artifacts are repository-generated evidence, not a formal compliance or penetration-test attestation.
- When behavior changes, change the fixture and expected result in the same pull request so review can see the contract change.
