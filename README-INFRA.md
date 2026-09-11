# ZeaZDev MikroTik / PoliceDBC

Production-safe RouterOS 7.24+ configuration for PoliceDBC RB4011.

## Current production topology
- RouterOS 7.24.2
- WAN: ether1 = 192.168.205.251/21
- Upstream gateway: 192.168.200.1
- LAN: bridge-lan = 192.168.1.1/24
- DHCP: 192.168.1.50-192.168.1.199
- WireGuard: wg-remote = 10.8.0.1/24, UDP 51820
- CORE peer: 10.8.0.2/32
- CORE MAC: 00:0C:29:75:A6:D4

## Production workflow
1. PRECHECK
2. backup/export
3. import dry-run
4. Safe Mode
5. apply only required idempotent phases
6. verify management/WAN/DNS/DHCP/WireGuard
7. exit Safe Mode only after verification

The old PPPoE / clean-slate design is legacy and must not be used against current PoliceDBC production.
