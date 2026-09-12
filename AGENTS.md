# zOS Agent Operating Contract

This file is the canonical operating contract for Codex and other automated agents working in `cvsz/zos`.

## Canonical environments

| Environment | FQDN | SSH user | Purpose |
|---|---|---|---|
| DEV | `core.zeaz.dev` | `zeazdev` | development, zOS controller, automation |
| PROD | `prod.zeaz.dev` | `zeazdev` | production workloads |

Do not reintroduce the legacy DBC hostname into new automation.

## Router baseline

- Device: MikroTik RB4011iGS+
- RouterOS baseline: `7.24.2`
- WAN: `ether1 = 192.168.205.251/21`
- Upstream gateway: `192.168.200.1`
- LAN: `bridge-lan = 192.168.1.1/24`
- DHCP pool: `192.168.1.50-192.168.1.199`
- WireGuard: `wg-remote = 10.8.0.1/24`, UDP `51820`
- DEV/CORE peer: `10.8.0.2/32`

## Mandatory change sequence

For production-sensitive RouterOS changes:

1. audit current state;
2. verify recovery-capable management access;
3. create/export backup evidence;
4. run static validation;
5. dry-run RouterOS imports where supported;
6. use Safe Mode for risky live changes;
7. require explicit operator opt-in;
8. apply the minimum idempotent change;
9. verify management, WAN, routing, DNS, WireGuard, firewall/NAT and target behavior;
10. retain post-change evidence.

Never treat HTTP 200 alone as proof that a RouterOS REST `/rest/execute` command succeeded.

## Prohibited actions

- Never factory-reset production.
- Never bulk-delete firewall, NAT, IP, interface or routing state.
- Never rotate WireGuard keys without explicit approval.
- Never change WAN/default route without a verified recovery path.
- Never disable both SSH and WinBox in the same change.
- Never migrate `192.168.1.0/24` without a cutover plan.
- Never place physical LAN `192.168.1.0/24` in CORE WireGuard `AllowedIPs`.
- Never commit credentials, private keys, runner credentials, sensitive exports or RouterOS binary backups.
- Never run live production RouterOS apply steps from normal CI.
- Never invent unverified PROD addresses.

## Active RouterOS phases

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

Historical `01-...` through `07-...` scripts and old one-click/meta-master paths are deprecated.

## CORE network invariant

```text
default via 192.168.1.1 dev ens33
192.168.1.0/24 dev ens33
10.8.0.0/24 dev policedbc
```

If the physical LAN route is on `policedbc`, repair the route/AllowedIPs conflict before production automation.

## GitHub Actions runner

- Display name: `zOS-Runner`
- Host path: `D:\zOS-Runner`
- Labels: `self-hosted`, `Windows`, `X64`
- Launch model: Scheduled Task `zOS-GitHub-Runner`

GitHub schedules by labels, not display name. Normal skills validation remains GitHub-hosted; the self-hosted runner is an explicit/manual probe until its worker runtime is proven healthy end-to-end.

Do not manually start a second `run.cmd` while the Scheduled Task listener is already running.

## Validation

Before merge-ready changes:

```bash
make validate
./zOS/bin/zos help
```

Operational commands:

```bash
make core-status
make core-check
make status
make audit
make backup
make dry-run
make verify
make e2e
```

Live apply remains gated:

```bash
export OMEGA_ALLOW_LIVE_APPLY=1
make apply
```

Automatic RouterOS installation remains double-gated:

```env
OMEGA_AUTO_ROUTEROS_UPDATE=0
OMEGA_ALLOW_ROUTER_REBOOT=0
```

## Documentation contract

Keep these synchronized when behavior changes:

- `README.md`
- `AGENTS.md`
- `CLAUDE.md`
- `GEMINI.md`
- `ENVIRONMENTS.md`
- `CHECKLIST.md`
- `SECURITY.md`
- `CONTRIBUTING.md`
- `docs/RUNBOOK.md`
- `docs/DISASTER-RECOVERY.md`
- `docs/SELF_HOSTED_RUNNER.md`
- `docs/zOS.md`
- `skills/README.md`

`AGENTS.md` is canonical. `CLAUDE.md` and `GEMINI.md` point back to this contract and add tool-specific notes.
