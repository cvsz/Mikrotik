# Changelog

## v2.1 - Real ZeaZDev environment naming
- Canonical DEV host is now `core.zeaz.dev`.
- Canonical PROD host is now `prod.zeaz.dev`.
- SSH user for both environments is `zeazdev`.
- Removed DBC naming from current documentation and agent guardrails.
- Added explicit environment inventory.
- Preserved PoliceDBC RouterOS 7.24.2 production baseline and safe-change workflow.

## v2.0 - PoliceDBC production-safe refactor
- Replaced clean-slate assumptions with current PoliceDBC topology.
- Added hard prechecks for WAN, LAN, default route and WireGuard.
- Added Safe Mode / dry-run / backup deployment workflow.
- Removed production dependency on PPPoE and 192.168.10.0/24.
- Preserved existing WireGuard keys and management access.
- Treated dual CORE DHCP client-id state as an operator-reconciliation item.
- Historical destructive one-click configuration deprecated for PoliceDBC.

## v1.0 FINAL
- Initial clean-slate PPPoE design.
