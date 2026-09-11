# ZeaZDev MikroTik – Real Infrastructure

## Environments

### DEV
- FQDN: `core.zeaz.dev`
- Environment: `dev`
- SSH user: `zeazdev`

### PROD
- FQDN: `prod.zeaz.dev`
- Environment: `production`
- SSH user: `zeazdev`

## Router

PoliceDBC RB4011:
- RouterOS 7.24.2
- WAN `ether1 = 192.168.205.251/21`
- Upstream `192.168.200.1`
- LAN `bridge-lan = 192.168.1.1/24`
- DHCP `192.168.1.50-192.168.1.199`
- WireGuard `wg-remote = 10.8.0.1/24`
- DEV/CORE WireGuard peer `10.8.0.2/32`

The previous clean-slate PPPoE/192.168.10.0 design is legacy-only and must not be applied to this production router.
