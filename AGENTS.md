# OMEGA / Codex RouterOS Production Rules

Repository target: cvsz/Mikrotik
Production router: PoliceDBC

## Mandatory behavior
- Audit before mutation.
- Back up/export before mutation.
- Use RouterOS import dry-run before apply.
- Use Safe Mode for production changes.
- Preserve current management access.
- Prefer idempotent find/set/add-if-missing logic.
- Never run destructive clean-all logic against production.
- Never rotate WireGuard keys without explicit operator approval.
- Never change WAN/default route unless the task explicitly requires it.
- Never disable both SSH and WinBox.
- Do not migrate the production LAN away from 192.168.1.0/24 without an explicit migration plan.

## Current production constants
- WAN interface: ether1
- WAN IP: 192.168.205.251/21
- WAN gateway: 192.168.200.1
- LAN bridge: bridge-lan
- LAN gateway: 192.168.1.1/24
- DHCP pool: 192.168.1.50-192.168.1.199
- WireGuard interface: wg-remote
- WireGuard router address: 10.8.0.1/24
- WireGuard CORE peer: 10.8.0.2/32
- WireGuard port: 51820

All generated production changes must preserve recovery access and be individually reviewable.
