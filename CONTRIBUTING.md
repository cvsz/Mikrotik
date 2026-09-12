# Contributing to zOS

zOS manages production-sensitive network automation. Contributions are evaluated for correctness, recoverability, idempotence, evidence, and operational clarity—not only whether code runs.

## Workflow

1. branch from current `main`;
2. inspect the existing runtime/repository contract before editing;
3. make the smallest coherent change;
4. update tests/evidence and documentation together;
5. run the applicable validation matrix;
6. open a pull request using the repository template;
7. require CI to pass and resolve review conversations before merge;
8. prefer squash merge for a focused PR.

## Required local baseline

~~~bash
make validate
make docs
./zOS/bin/zos help
~~~

When relevant:

~~~bash
make evidence
make security-evidence
make core-check
make status
make audit
make verify
~~~

Do not use normal CI as a live RouterOS control channel.

## Shell files and Git modes

Operational entry points are executed directly from the Makefile. When adding a shell entry point, commit it with executable mode (`100755`) rather than relying on runtime `chmod`. A permission-denied exit 126 in a normal Git checkout is a repository/file-mode defect until proven otherwise.

## RouterOS changes

- audit and back up before mutation;
- dry-run before live apply;
- preserve management access;
- use Safe Mode/recovery access for risky changes;
- require explicit live-change opt-in;
- prefer stable names/comments or looked-up IDs over fragile internal IDs;
- verify resulting state independently;
- do not treat HTTP 200 from RouterOS REST execution as semantic success.

## Documentation ownership

`docs/INDEX.md` is the documentation map. Project-owned Markdown should be updated with the implementation. Vendored `skills/routeros-*` Markdown follows upstream provenance and is not subject to blanket rewriting.

## Secrets

Never commit passwords, tokens, SSH/WireGuard private keys, runner registration material, RouterOS binary backups, sensitive exports, or populated local topology files.

## Pull request acceptance

A PR should state scope, risk, validation, documentation impact, recovery/rollback, and whether any live system was changed. If no live system was changed, say so explicitly.
