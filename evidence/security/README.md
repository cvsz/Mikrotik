# Security Evidence

zOS security evidence is generated from the repository state rather than hand-written as a claim of external certification.

The CI evidence workflow produces:

- `spdx-files.json` — SPDX 2.3 file inventory with SHA-256 checksums for tracked files;
- `secret-audit.sarif` — SARIF 2.1.0 output from the repository secret-pattern audit;
- `audit-report.json` — summary of checked files, findings, and generator version.

These artifacts are evidence of the checks performed by this repository only. They are **not** a substitute for an independent penetration test, CodeQL/third-party SAST, dependency vulnerability scanning, or a formal compliance attestation.

Generate locally:

```bash
python3 tools/generate-security-evidence.py --out artifacts/security
```

The generator is fail-closed: if a high-confidence secret pattern is detected in a tracked file, it records a SARIF finding and returns a non-zero exit code.
