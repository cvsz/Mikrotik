# zOS Evidence Corpus

`evidence/` contains deterministic, sanitized repository fixtures. It is not a storage location for raw production logs or credentials.

## Layout

- `corpus/analyzer/golden.jsonl` — analyzer regression cases;
- `corpus/rag/ranking.jsonl` — retrieval/ranking expectations;
- `corpus/pr-salvage/cases.jsonl` — PR salvage/cleanup cases;
- `corpus/discussions/triage.jsonl` — discussion triage cases;
- `harness/compatibility.json` — agent-adapter compatibility expectations;
- `ci/failure-modes.jsonl` — sanitized failure signatures and expected diagnosis;
- `security/README.md` — generated security-evidence contract.

## Commands

~~~bash
make evidence
make security-evidence
~~~

## Boundary

Repository evidence proves only the checks and fixtures represented here. Live CORE/router acceptance requires the runtime evidence defined in `docs/PRODUCTION-READINESS.md` and `docs/EVIDENCE-MATRIX.md`.

Fixtures must never contain real credentials, private keys, runner tokens, sensitive exports, binary backups, or raw private incident data.
