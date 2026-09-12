# Security Evidence

zOS generates repository-derived security evidence instead of making unsupported certification claims.

Generated artifacts include:

- `spdx-files.json` — SPDX 2.3 file inventory/checksums;
- `secret-audit.sarif` — SARIF output from repository secret-pattern checks;
- `audit-report.json` — generator/check summary.

Generate locally:

~~~bash
make security-evidence
~~~

The generator fails closed when a high-confidence tracked-source secret pattern is found.

These artifacts are not a penetration test, formal compliance attestation, dependency vulnerability assessment, or proof that the live network is securely configured. See `SECURITY.md` and `docs/EVIDENCE-MATRIX.md`.
