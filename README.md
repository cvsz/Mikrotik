# ZeaZDev MikroTik / PoliceDBC

Production-safe RouterOS 7.24+ configuration and automation for the PoliceDBC RB4011.

## Current production topology

- RouterOS: 7.24.2
- Router: RB4011iGS+
- WAN: ether1 = 192.168.205.251/21
- Upstream gateway: 192.168.200.1
- LAN: bridge-lan = 192.168.1.1/24
- LAN DHCP: 192.168.1.50-192.168.1.199
- WireGuard: wg-remote = 10.8.0.1/24, UDP 51820
- CORE peer: 10.8.0.2/32
- CORE LAN MAC: 00:0C:29:75:A6:D4

## Safety model

This repository no longer treats production deployment as a destructive clean-slate install.

Mandatory workflow:

1. `00-PRECHECK.rsc`
2. `10-BACKUP-SNAPSHOT.rsc`
3. Run any change with RouterOS `/import ... verbose=yes dry-run`
4. Enable Safe Mode before production apply
5. Apply only idempotent phase scripts required for the target state
6. Run `99-VERIFY-HEALTH.rsc`
7. Exit Safe Mode only after management, WAN, DNS, DHCP and WireGuard verification

## Production guardrails

Never automatically:
- reset configuration
- remove all firewall/NAT/IP/interface state
- change WAN IP/default gateway
- replace WireGuard private keys
- disable both SSH and WinBox
- change LAN subnet
- delete L2TP/PPP configuration until explicitly decommissioned
- assume PPPoE on PoliceDBC

Legacy destructive scripts remain for historical reference but must not be used against PoliceDBC production.

## CORE-side Codex controller

Use `tools/install-omega-codex-mikrotik.sh` on the Ubuntu CORE host. Codex must run on CORE, not on RouterOS.
