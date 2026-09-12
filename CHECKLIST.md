# zOS Production Checklist

Use this checklist for repository merges and live infrastructure changes. Repository readiness and runtime readiness are separate gates.

## Repository/PR

- [ ] Change is scoped, reviewable, and recovery-aware.
- [ ] `make validate` passes.
- [ ] `make docs` passes.
- [ ] `make evidence` passes when evidence/agent behavior is affected.
- [ ] `make security-evidence` passes when security evidence is affected.
- [ ] Required GitHub Actions checks are green.
- [ ] No secret, private key, runner credential, binary backup, or sensitive production export is committed.
- [ ] Operational scripts that are executed directly retain executable Git mode.
- [ ] Relevant documentation and `CHANGELOG.md` are updated.
- [ ] PR template safety/recovery questions are answered.

## CORE

- [ ] `ens33` has carrier and a valid runtime IPv4 address.
- [ ] Default gateway resolves through `ens33`.
- [ ] `192.168.1.0/24` routes through `ens33`.
- [ ] `10.8.0.0/24` routes through `policedbc`.
- [ ] Active `/etc/wireguard/*.conf` does not place `192.168.1.0/24` in `AllowedIPs`.
- [ ] `make core-check` passes.
- [ ] `make core-find-conflict` passes.
- [ ] OpenSSH configuration validates.
- [ ] SSH public-key login is proven from another host.
- [ ] `PasswordAuthentication no` is effective for production.
- [ ] `PermitRootLogin no` is effective.
- [ ] A reboot persistence test has been completed after network/SSH recovery.

## Router change

- [ ] Recovery-capable local/MAC/console/management path is available.
- [ ] `make status` and `make audit` reviewed.
- [ ] Current export and backup captured.
- [ ] Intended phases pass `make dry-run`.
- [ ] Risky work uses Safe Mode or an equivalent verified rollback path.
- [ ] `OMEGA_ALLOW_LIVE_APPLY=1` is set only for the approved window.
- [ ] Management remains reachable during and after change.
- [ ] WAN/default route, LAN/DHCP/DNS, WireGuard, firewall/NAT, and target behavior are independently verified.
- [ ] `make verify` and `make e2e` pass when applicable.
- [ ] Post-change evidence and rollback notes are retained.

## GitHub

- [ ] Main branch ruleset blocks force-push/delete and requires PR review/checks.
- [ ] Workflow default permissions are read-only; package write is scoped to the build workflow.
- [ ] Untrusted fork code does not run on the privileged self-hosted runner.
- [ ] `zOS-Runner` has a single listener session.
- [ ] Private vulnerability reporting / secret scanning / push protection are enabled where supported.
- [ ] Release tag, changelog, artifacts, and GHCR image agree for a release.
