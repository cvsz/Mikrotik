# zOS for MikroTik

[![Validate RouterOS Stack](https://github.com/cvsz/zos/actions/workflows/validate.yml/badge.svg)](https://github.com/cvsz/zos/actions/workflows/validate.yml)
[![Build zOS](https://github.com/cvsz/zos/actions/workflows/zos-build.yml/badge.svg)](https://github.com/cvsz/zos/actions/workflows/zos-build.yml)
[![Evidence Validation](https://github.com/cvsz/zos/actions/workflows/evidence-validation.yml/badge.svg)](https://github.com/cvsz/zos/actions/workflows/evidence-validation.yml)
[![RouterOS Skills](https://github.com/cvsz/zos/actions/workflows/routeros-skills.yml/badge.svg)](https://github.com/cvsz/zos/actions/workflows/routeros-skills.yml)

zOS is the ZeaZDev management and safety control plane for MikroTik RouterOS. RouterOS remains the network operating system on the router; zOS runs from the controller side and adds deterministic planning, validation, backup, evidence, guarded apply, verification, recovery, and GitHub delivery workflows.

> Production rule: normal CI is validation/build/evidence only. Live RouterOS mutation remains operator-gated and recovery-aware.

## Current verified invariants

- Repository: `cvsz/zos`, default branch `main`.
- DEV/controller FQDN: `core.zeaz.dev`.
- PROD FQDN: `prod.zeaz.dev`.
- Router baseline: MikroTik RB4011iGS+, RouterOS 7.24.2+, LAN `192.168.1.1/24`, WAN `192.168.205.251/21`, upstream `192.168.200.1`.
- CORE physical interface: `ens33`; WireGuard interface: `policedbc`.
- CORE routing contract:

~~~text
default via 192.168.1.1 dev ens33
192.168.1.0/24 dev ens33
10.8.0.0/24 dev policedbc
~~~

- `192.168.1.0/24` must never be an active `AllowedIPs` route on `policedbc`.
- CORE SSH is fail-closed toward public-key authentication: password login is disabled by default by `core/install.sh`, and the installer refuses to disable passwords unless an authorized key is already present.

Observed DHCP addresses are runtime evidence, not topology invariants. Do not hard-code a transient DEV LAN address into automation.

## Quick start

~~~bash
git clone https://github.com/cvsz/zos.git
cd zos
cp config/topology.env.example config/topology.env
chmod 600 config/topology.env
./tools/install-controller.sh
./zOS/bin/zos doctor
make validate
make docs
~~~

Operational shell entry points are tracked executable in Git. If a checked-out file unexpectedly returns exit 126/permission denied, diagnose the checkout/filesystem mode instead of adding ad-hoc `chmod` instructions to normal installation.

## Operator workflow

~~~bash
make validate
make docs
make evidence
make security-evidence
make core-check
make status
make audit
make backup
make dry-run
make verify
make e2e
~~~

Live apply remains blocked unless the operator explicitly enables it after backup, dry-run, and a verified recovery path:

~~~bash
export OMEGA_ALLOW_LIVE_APPLY=1
make apply
~~~

Automatic RouterOS installation is separately double-gated by `OMEGA_AUTO_ROUTEROS_UPDATE=1` and `OMEGA_ALLOW_ROUTER_REBOOT=1`.

## CORE recovery

For SSH/LAN recovery on CORE:

~~~bash
cd /home/<repo-owner>/zos
git pull --ff-only origin main
sudo ./core/install.sh
make core-check
make core-find-conflict
~~~

Run Git as the repository owner. Do not solve Git dubious-ownership errors by globally trusting a user-owned working tree. See `core/README.md`, `docs/NETWORK-RECOVERY.md`, and `docs/SSH-HARDENING.md`.

## Documentation map

Start at `docs/INDEX.md`. Key documents:

- `AGENTS.md` — canonical agent and production-safety contract.
- `docs/ARCHITECTURE.md` — zOS architecture and trust boundaries.
- `docs/INSTALLATION.md` — supported installation/bootstrap paths.
- `docs/RUNBOOK.md` — end-to-end operator procedure.
- `docs/NETWORK-RECOVERY.md` — CORE LAN/WireGuard recovery.
- `docs/SSH-HARDENING.md` — SSH key-only production baseline.
- `docs/PRODUCTION-READINESS.md` — repository vs live-runtime acceptance.
- `docs/GITHUB-OPERATIONS.md` and `docs/GITHUB-SETTINGS.md` — GitHub workflows and repository governance.
- `docs/TESTING.md` — validation matrix.
- `docs/RELEASES.md` — release/package procedure.
- `docs/DISASTER-RECOVERY.md` — rollback and recovery.
- `SECURITY.md` — security policy and reporting.
- `SUPPORT.md` — support channels and issue hygiene.

Vendored RouterOS skills under `skills/routeros-*` preserve upstream/provenance semantics and are not rewritten as project-owned documentation. See `skills/README.md` and `THIRD_PARTY_NOTICES.md`.

## Repository status is not production status

A green GitHub build proves the repository checks that ran. It does not prove live router reachability, DNS, WireGuard, firewall/NAT behavior, recovery access, or PROD connectivity. Production acceptance requires the runtime evidence defined in `docs/PRODUCTION-READINESS.md`.
