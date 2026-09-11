# ZeaZDev MikroTik / PoliceDBC

Production-safe RouterOS 7.24+ configuration and end-to-end automation for the real ZeaZDev DEV/PROD topology.

## Canonical environments

| Environment | FQDN | SSH user | Role |
|---|---|---|---|
| DEV | `core.zeaz.dev` | `zeazdev` | development, network controller, Codex/OMEGA |
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

## CORE controller setup

On `core.zeaz.dev`:

```bash
git clone https://github.com/cvsz/Mikrotik.git
cd Mikrotik
cp config/topology.env.example config/topology.env
chmod +x tools/*.sh
./tools/install-controller.sh
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
```

Live apply is deliberately blocked by default. After successful backup + dry-run, enter RouterOS Safe Mode through a recovery-capable management session, then explicitly opt in:

```bash
export OMEGA_ALLOW_LIVE_APPLY=1
make apply
```

Do not exit Safe Mode until `make verify` and independent management checks pass.

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

## CI and safety controls

`.github/workflows/validate.yml` checks required files, canonical topology, destructive RouterOS patterns, shell scripts, and obvious embedded secrets/private keys. Live deployment is never performed by GitHub Actions.

## Documentation

- `ENVIRONMENTS.md` — canonical environment inventory
- `docs/RUNBOOK.md` — complete install/dry-run/apply/verify procedure
- `docs/DISASTER-RECOVERY.md` — rollback/recovery order
- `CHECKLIST.md` — production acceptance checklist
- `AGENTS.md` — Codex/AI production guardrails

Codex/AI automation belongs on `core.zeaz.dev`, not inside RouterOS.
