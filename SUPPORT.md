# Support

## Where to ask

- Bugs or reproducible repository defects: GitHub Issues.
- Feature/design proposals: GitHub Issues or Discussions when enabled.
- Pull-request implementation questions: the relevant PR conversation.
- Security vulnerabilities or exposed credentials: follow `SECURITY.md`; do not open a public issue with exploitable details.

## Before opening an issue

Run the applicable diagnostics and include sanitized output:

~~~bash
make validate
make docs
./zOS/bin/zos doctor
~~~

For CORE networking:

~~~bash
make core-status
make core-check
make core-find-conflict
~~~

For router operations, provide the failing command/phase and sanitized evidence without credentials, private keys, tokens, binary backups, or sensitive exports.

## Include

- zOS commit SHA or release tag;
- operating system/platform;
- exact command and exit code;
- expected vs actual behavior;
- whether the issue affects repository validation, CORE, router, GitHub Actions, self-hosted runner, or GHCR;
- whether any live production change was attempted;
- recovery/rollback status if relevant.

## Do not include

Passwords, access tokens, private keys, runner credentials, full sensitive topology dumps, private URLs containing credentials, or raw logs that contain secrets.
