# OMEGA / Codex RouterOS Production Rules

## Real ZeaZDev environment map
- DEV: core.zeaz.dev
- PROD: prod.zeaz.dev
- SSH user for both: zeazdev

Do not invent or reintroduce the old DBC hostname in new configuration.

## PoliceDBC production constants
- WAN interface: ether1
- WAN IP: 192.168.205.251/21
- WAN gateway: 192.168.200.1
- LAN bridge: bridge-lan
- LAN gateway: 192.168.1.1/24
- DHCP pool: 192.168.1.50-192.168.1.199
- WireGuard interface: wg-remote
- WireGuard router address: 10.8.0.1/24
- DEV/CORE peer: 10.8.0.2/32
- WireGuard port: 51820

## Mandatory behavior
- Audit before mutation.
- Back up/export before mutation.
- Dry-run imports before apply.
- Use Safe Mode for production changes.
- Preserve current management access.
- Prefer idempotent changes.
- Never factory-reset production.
- Never delete all firewall/NAT/IP/interface state.
- Never rotate WireGuard keys without explicit approval.
- Never change WAN/default route unless explicitly required.
- Never disable both SSH and WinBox.
- Never migrate 192.168.1.0/24 without a migration plan.
- Keep DEV and PROD as separate environments.
