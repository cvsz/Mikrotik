# Production Readiness

Production readiness is an evidence state, not a label inferred from CI.

## Repository-ready

A commit/PR is repository-ready when:

- `make validate` passes;
- `make docs` passes;
- relevant evidence/security checks pass;
- required GitHub Actions checks are green;
- live mutation paths remain fail-closed;
- no sensitive material is committed;
- documentation, rollback implications, and changelog are synchronized.

## CORE-ready

CORE is runtime-ready when:

- physical carrier and runtime IPv4 are valid;
- default/physical LAN route through `ens33`;
- `10.8.0.0/24` routes through `policedbc`;
- active WireGuard config excludes `192.168.1.0/24` from `AllowedIPs`;
- sshd validates and listens;
- public-key login is independently proven;
- password authentication is disabled for production;
- root SSH login is disabled;
- APT trust remains signature-verified;
- any network/SSH recovery survives reboot.

## Router change-ready

- current state audited;
- recovery-capable management path proven;
- export and backup captured;
- intended phases dry-run cleanly;
- Safe Mode/recovery available for risky changes;
- explicit live-apply gate enabled only for the approved window.

## Production accepted

After an approved live change, independently verify management, WAN/default route, LAN/DHCP/DNS, WireGuard, firewall/NAT, intended service behavior, and DEV/PROD reachability where applicable.

Record:

1. commit/release SHA;
2. CI run identifiers;
3. pre-change audit timestamp;
4. backup/export identifiers;
5. dry-run result;
6. approved change window/operator;
7. post-change verification result;
8. reboot/rollback/restore result when relevant;
9. remaining known risks.

## Explicit non-evidence

The following are not sufficient on their own: HTTP 200 from a RouterOS execute endpoint, successful repository build, an SSH TCP port being reachable, a pre-reboot route table, or a backup file existing without a restore/rollback exercise.
