# PoliceDBC / ZeaZDev Production Checklist

## Identity
- DEV is `core.zeaz.dev`
- PROD is `prod.zeaz.dev`
- SSH user is `zeazdev`

## Before change
- Confirm recovery path.
- Confirm SSH or WinBox access.
- Run `00-PRECHECK.rsc`.
- Export and backup.
- Dry-run every candidate import.
- Enter RouterOS Safe Mode.

## After change
- LAN gateway remains `192.168.1.1/24` on `bridge-lan`.
- WAN remains `192.168.205.251/21` on `ether1`.
- Default route remains via `192.168.200.1`.
- Internet and DNS pass.
- SSH and WinBox remain reachable.
- `wg-remote` keys and peer are preserved.
- DEV/CORE remains the `10.8.0.2/32` WireGuard peer.
- Run `99-VERIFY-HEALTH.rsc`.
