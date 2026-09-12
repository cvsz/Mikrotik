# zOS Operations

zOS is the ZeaZDev controller-side management/safety layer for MikroTik RouterOS.

## Operating principles

- fail closed;
- preserve management/recovery access;
- audit and back up before mutation;
- dry-run before mutation;
- explicit live-apply/update/reboot gates;
- independent verification;
- no secrets in source control;
- keep repository evidence distinct from live runtime evidence.

## CLI

~~~bash
./zOS/bin/zos doctor
./zOS/bin/zos status
./zOS/bin/zos audit
./zOS/bin/zos backup
./zOS/bin/zos plan
./zOS/bin/zos verify
./zOS/bin/zos update-check
./zOS/bin/zos update-notify
./zOS/bin/zos update-auto
./zOS/bin/zos e2e
~~~

Use `make` targets when following the repository runbook because they compose the same operational entry points with consistent names.

## Architecture

See `docs/ARCHITECTURE.md`. The controller does not replace RouterOS and GitHub Actions does not become the live router control plane.

## Package

`zos-build.yml` creates a tarball/checksum and multi-architecture controller image:

~~~text
ghcr.io/cvsz/mikrotik-zos
~~~

The image is controller-side software, not RouterOS firmware.

## Update safety

Read-only update checks are allowed by default. Unattended install requires both explicit auto-update and reboot gates. The intended sequence is backup -> pre-update verification -> install/reboot -> wait for return -> post-update verification -> optional report.

## REST semantics

Transport-level HTTP success from RouterOS execution is not sufficient. Important changes require response-content validation and independent state verification.

## Documentation

Use `docs/INDEX.md` as the documentation map and `docs/PRODUCTION-READINESS.md` for acceptance language.
