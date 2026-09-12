# Production Readiness

This document distinguishes repository readiness from live infrastructure readiness.

## Repository readiness

A merge candidate is repository-ready when:

- `make validate` passes;
- `make evidence` passes;
- `make security-evidence` succeeds;
- GitHub Actions validation/build/evidence workflows are green;
- production mutation paths remain fail-closed;
- no secret, private key, runner credential, sensitive export, or RouterOS binary backup is committed;
- operational and agent documentation is synchronized.

## CORE readiness

`core.zeaz.dev` is runtime-ready when:

- the physical interface has carrier and a valid IPv4 address;
- the physical LAN and default gateway route through the physical interface, not `policedbc`;
- `192.168.1.0/24` is absent from persistent `policedbc` WireGuard `AllowedIPs`;
- OpenSSH configuration validates and the listener is active;
- SSH public-key login is proven;
- password authentication is disabled by default;
- any explicit temporary password-authentication exception is removed after bootstrap;
- APT signature verification remains enabled;
- a repaired HashiCorp package signing key matches the fingerprint pinned in `core/install.sh`.

## Router readiness

PoliceDBC is change-ready only after:

- current state is audited;
- local/recovery-capable management access is proven;
- text export and backup evidence exist;
- intended phases pass dry-run;
- Safe Mode/recovery procedure is available for risky live work;
- `OMEGA_ALLOW_LIVE_APPLY=1` is set only for an approved change window;
- post-change `make verify` and independent management checks pass.

## Production acceptance

Do not label the deployment fully production-ready based on CI alone. Final acceptance requires live evidence from CORE and the router, including routing, DNS, WireGuard, firewall/NAT, management access, and intended DEV/PROD reachability.

A completed acceptance record should contain:

1. commit/release SHA;
2. CI run identifiers;
3. pre-change audit timestamp;
4. backup/export identifiers;
5. dry-run result;
6. approved live-change window if mutation occurred;
7. post-change verification result;
8. rollback/recovery result if exercised;
9. operator identity and timestamp.
