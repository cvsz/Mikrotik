# zOS for MikroTik

[![zOS RouterOS Skills Validation](https://github.com/cvsz/zos/actions/workflows/routeros-skills.yml/badge.svg)](https://github.com/cvsz/zos/actions/workflows/routeros-skills.yml)
[![Validate RouterOS Stack](https://github.com/cvsz/zos/actions/workflows/validate.yml/badge.svg)](https://github.com/cvsz/zos/actions/workflows/validate.yml)
[![Build zOS](https://github.com/cvsz/zos/actions/workflows/zos-build.yml/badge.svg)](https://github.com/cvsz/zos/actions/workflows/zos-build.yml)
[![GitHub last commit](https://img.shields.io/github/last-commit/cvsz/zos)](https://github.com/cvsz/zos/commits/main)
[![GitHub issues](https://img.shields.io/github/issues/cvsz/zos)](https://github.com/cvsz/zos/issues)
[![GitHub pull requests](https://img.shields.io/github/issues-pr/cvsz/zos)](https://github.com/cvsz/zos/pulls)
[![RouterOS](https://img.shields.io/badge/RouterOS-7.24%2B-293239)](https://help.mikrotik.com/docs/)
[![Runner](https://img.shields.io/badge/runner-self--hosted%20Windows%20x64-0078D4)](docs/SELF_HOSTED_RUNNER.md)
[![GHCR](https://img.shields.io/badge/package-GHCR-blue)](https://github.com/users/cvsz/packages?repo_name=zos)

Production-safe RouterOS automation, zOS control-plane tooling, RouterOS AI/operator skills, update monitoring, backup, validation, and end-to-end operations for the ZeaZDev network.

> zOS runs as the management/control layer. RouterOS remains the trusted network operating system on the MikroTik device.

## Status surfaces

| Surface | Purpose |
|---|---|
| `routeros-skills.yml` | validates imported RouterOS skills on the self-hosted Windows x64 runner |
| `validate.yml` | static repository, shell, safety, and secret validation |
| `zos-build.yml` | builds zOS artifacts and OCI/GHCR packages |
| `zOS-Runner` | repository self-hosted Windows x64 runner for RouterOS skill validation |
| GHCR | published zOS OCI package surface |

## Canonical environments

| Environment | FQDN | SSH user | Role |
|---|---|---|---|
| DEV | `core.zeaz.dev` | `zeazdev` | development, network controller, Codex/OMEGA/zOS |
| PROD | `prod.zeaz.dev` | `zeazdev` | production workloads |

Do not use the old DBC hostname in new automation. `PROD_LAN_IP` and `PROD_WG_IP` remain intentionally unset until verified from the real production host/router.

## PoliceDBC router baseline

- MikroTik RB4011iGS+
- RouterOS `7.24.2`
- WAN `ether1 = 192.168.205.251/21`
- Upstream gateway `192.168.200.1`
- LAN `bridge-lan = 192.168.1.1/24`
- DHCP pool `192.168.1.50-192.168.1.199`
- WireGuard `wg-remote = 10.8.0.1/24`, UDP `51820`
- DEV/CORE WireGuard peer `10.8.0.2/32`

## RouterOS skills

zOS vendors RouterOS-focused operational knowledge from `tikoci/routeros-skills` under `skills/` for agent grounding and CI validation. Current imported set:

```text
routeros-app-yaml
routeros-command-tree
routeros-container
routeros-firewall
routeros-fundamentals
routeros-hotspot
routeros-mac-telnet
routeros-mndp
routeros-netinstall
routeros-qemu-chr
routeros-quickchr
routeros-scripting
routeros-sniffer
routeros-syntax-inspection
```

See `skills/README.md` and `THIRD_PARTY_NOTICES.md` for provenance and attribution.

## Active production phases

```text
00-PRECHECK.rsc
10-BACKUP-SNAPSHOT.rsc
20-NETWORK-NORMALIZE.rsc
30-DHCP-DNS-NTP.rsc
40-WIREGUARD-SERVICES.rsc
50-FIREWALL-NAT.rsc
60-OBSERVABILITY.rsc
90-EXPORT-EVIDENCE.rsc
99-VERIFY-HEALTH.rsc
```

The historical clean-slate PPPoE scripts and `zeaz-meta-master-oneclick.rsc` are not valid for the current production topology.

## Quick start

On `core.zeaz.dev`:

```bash
git clone https://github.com/cvsz/zos.git
cd zos
cp config/topology.env.example config/topology.env
chmod 600 config/topology.env
chmod +x tools/*.sh zOS/bin/zos zOS/install.sh
./tools/install-controller.sh
./zOS/bin/zos doctor
```

The controller creates a dedicated SSH key, does not store a router password, and does not modify the live router during installation.

## Operator workflow

```bash
make validate       # static topology/safety/shell checks
make core-status    # inspect DEV/CORE network
make core-check     # verify ens33 / physical-LAN routing
make status         # router read-only status
make audit          # complete read-only RouterOS audit
make backup         # export + binary backup
make dry-run        # upload and dry-run every active RouterOS phase
make verify         # router reachability / route / WG / DNS checks
make e2e            # DEV -> router -> PROD end-to-end smoke checks
make update-check   # check RouterOS update status
```

Live apply is deliberately blocked by default. After successful backup + dry-run, enter RouterOS Safe Mode through a recovery-capable management session, then explicitly opt in:

```bash
export OMEGA_ALLOW_LIVE_APPLY=1
make apply
```

Do not exit Safe Mode until `make verify` and independent management checks pass.

## RouterOS update automation

Automatic installation remains fail-closed by default:

```env
ROUTEROS_UPDATE_CHANNEL=stable
OMEGA_AUTO_ROUTEROS_UPDATE=0
OMEGA_ALLOW_ROUTER_REBOOT=0
```

To perform an unattended RouterOS install, both explicit gates must be enabled. The update path performs backup, pre-update verification, install/reboot, post-reboot verification, and optional server reporting.

## CORE no-Internet recovery

The known failure mode is the physical `192.168.1.0/24` LAN being claimed by the `policedbc` WireGuard route while `ens33` has lost/changed carrier. Diagnose first:

```bash
make core-status
make core-check
```

If `ens33` has carrier and the LAN route is incorrectly on `policedbc`:

```bash
make core-repair
make core-find-conflict
```

Expected routing on DEV/CORE:

```text
default via 192.168.1.1 dev ens33
192.168.1.0/24 dev ens33
10.8.0.0/24 dev policedbc
```

Persistent WireGuard `AllowedIPs` must not install `192.168.1.0/24` through the tunnel.

## Self-hosted runner

The repository currently uses a Windows x64 self-hosted runner named `zOS-Runner`. GitHub Actions dispatches jobs by labels, so the skills workflow targets:

```yaml
runs-on: [self-hosted, Windows, X64]
```

The runner workflow is validation-only and does not apply RouterOS configuration. See `docs/SELF_HOSTED_RUNNER.md` for setup, maintenance, security, and troubleshooting.

## CI and safety controls

- required-file and canonical-topology validation
- destructive RouterOS pattern detection
- shellcheck on Linux-hosted workflows
- literal-secret/private-key checks
- imported RouterOS skill structure checks
- GHCR/OCI build path
- explicit live-change gates
- backup + dry-run + Safe Mode requirements
- no live RouterOS changes from normal CI

## Documentation

- `ENVIRONMENTS.md` — canonical environment inventory
- `docs/RUNBOOK.md` — complete install/dry-run/apply/verify procedure
- `docs/DISASTER-RECOVERY.md` — rollback/recovery order
- `docs/SELF_HOSTED_RUNNER.md` — `zOS-Runner` operations and hardening
- `docs/zOS.md` — zOS architecture and operations
- `CHECKLIST.md` — production acceptance checklist
- `AGENTS.md` — Codex/AI production guardrails
- `SECURITY.md` — security policy
- `CONTRIBUTING.md` — contribution workflow
- `THIRD_PARTY_NOTICES.md` — imported/upstream attribution

Codex/AI automation belongs on `core.zeaz.dev`, not inside RouterOS.
