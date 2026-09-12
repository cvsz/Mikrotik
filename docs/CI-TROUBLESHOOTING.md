# CI Failure-Mode Troubleshooting

This runbook maps known workflow failure signatures to a safe diagnostic path. The machine-readable reference set is `evidence/ci/failure-modes.jsonl`.

## Broken relative Markdown reference

Meaning: a vendored skill points at a local `.md` file that is not present in the repository.

Actions:

1. identify the source skill and exact relative target;
2. add the missing vendored/provenance file or remove the stale reference;
3. rerun `zOS RouterOS Skills Validation`;
4. do not disable link validation to make CI green.

## Runner session conflict

Signature: `A session for this runner already exists`.

Meaning: another listener already owns the registered runner session.

For zOS, first inspect Scheduled Task `zOS-GitHub-Runner`. Do not start a second `D:\zOS-Runner\run.cmd` while the scheduled listener is active.

## Runner worker initialization / secret masker

Signature includes `PowerShellPreAmpersandEscape` or `Worker.InitializeSecretMasker` before workflow step 1.

Actions:

1. inspect the newest `D:\zOS-Runner\_diag\Worker_*.log` and `Runner_*.log`;
2. run the minimal no-secret manual probe;
3. inspect repository/environment variables for malformed values without printing secret contents;
4. update/reinstall the runner only if the failure is reproducible and the registration path is understood.

## Secret scanner finding

Meaning: repository validation detected a high-confidence credential/private-key pattern.

Actions:

1. inspect the exact matched path;
2. remove/rotate real secrets immediately if present;
3. if it is a false positive, narrow the rule around the specific benign syntax without weakening coverage globally;
4. rerun both normal validation and generated security evidence.

## Image pull failure

Signature: `ImagePullBackOff`.

Actions:

1. verify the exact image registry/repository/tag from an authoritative source;
2. check registry credentials and network access;
3. verify architecture compatibility;
4. change the tag only after confirming the replacement exists.

## Evidence capture rule

Store only sanitized signatures and expected diagnoses in the repository. Do not commit raw logs containing tokens, private URLs, credentials, runner registration material, or production secrets.
