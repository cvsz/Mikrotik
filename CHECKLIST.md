# PoliceDBC Production Checklist

## Before change
- Confirm local/MAC recovery path.
- Confirm SSH or WinBox management works.
- Run 00-PRECHECK.rsc.
- Export and backup current configuration.
- Run every candidate import with verbose=yes dry-run.
- Enter RouterOS Safe Mode.

## After change
- LAN gateway remains 192.168.1.1/24 on bridge-lan.
- WAN remains 192.168.205.251/21 on ether1.
- Default route remains via 192.168.200.1.
- Internet and DNS pass.
- SSH and WinBox remain reachable.
- WireGuard peer/key is preserved and handshakes.
- DHCP has no unintended duplicate CORE lease.
- Run 99-VERIFY-HEALTH.rsc.
- Exit Safe Mode only after all checks pass.
