# ZeaZDev MikroTik / PoliceDBC

Production-safe RouterOS 7.24+ configuration for the real ZeaZDev DEV/PROD topology.

## Real environment naming

- DEV: `core.zeaz.dev` — user `zeazdev`
- PROD: `prod.zeaz.dev` — user `zeazdev`

Do not use the old DBC naming in new automation.

## PoliceDBC router baseline

- Router: MikroTik RB4011iGS+
- RouterOS: 7.24.2
- WAN: `ether1 = 192.168.205.251/21`
- Upstream gateway: `192.168.200.1`
- LAN: `bridge-lan = 192.168.1.1/24`
- DHCP pool: `192.168.1.50-192.168.1.199`
- Existing WireGuard: `wg-remote = 10.8.0.1/24`, UDP 51820
- DEV/CORE peer: `10.8.0.2/32`

## Safety workflow

1. Run `00-PRECHECK.rsc`
2. Run `10-BACKUP-SNAPSHOT.rsc`
3. Dry-run every candidate import
4. Enter RouterOS Safe Mode
5. Apply only required idempotent phases
6. Run `99-VERIFY-HEALTH.rsc`
7. Exit Safe Mode only after management/WAN/DNS/DHCP/WireGuard checks pass

Codex/AI automation belongs on `core.zeaz.dev`, not inside RouterOS.
