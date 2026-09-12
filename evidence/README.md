# zOS Evidence Corpus

This directory contains deterministic fixtures and generated-evidence contracts used to detect regressions across analyzer, retrieval/evaluation, PR salvage, discussion triage, harness adapters, security auditing, and CI troubleshooting.

## Layout

- `corpus/analyzer/golden.jsonl` — analyzer regression cases and expected findings.
- `corpus/rag/ranking.jsonl` — retrieval/evaluator ranking expectations.
- `corpus/pr-salvage/cases.jsonl` — stale/duplicate/reopen/review-thread cleanup cases.
- `corpus/discussions/triage.jsonl` — public discussion triage cases.
- `harness/compatibility.json` — cross-harness policy and adapter expectations.
- `ci/failure-modes.jsonl` — synthetic CI failure signatures and expected diagnoses.
- `security/README.md` — security evidence model and generated artifact contract.

Run:

```bash
python3 tools/validate-evidence.py
python3 tools/generate-security-evidence.py --out artifacts/security
```

Fixtures are intentionally synthetic. They must never contain real credentials, private keys, runner tokens, production exports, or sensitive incident data.
