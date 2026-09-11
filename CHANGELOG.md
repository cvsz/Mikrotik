# Changelog

## v2.0 - PoliceDBC production-safe refactor
- Replaced clean-slate assumptions with current PoliceDBC topology.
- Added hard prechecks for WAN, LAN, default route and WireGuard.
- Added Safe Mode / dry-run / backup deployment workflow.
- Removed production dependency on PPPoE and 192.168.10.0/24.
- Preserves existing WireGuard keys and management access.
- Treats dual CORE DHCP client-id state as an operator-reconciliation item.
- Historical destructive one-click configuration is deprecated for PoliceDBC.

## v1.0 FINAL
- Initial clean-slate PPPoE design.
