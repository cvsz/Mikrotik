# ZeaZDev Infrastructure Reference

This file is a compact infrastructure summary. `ENVIRONMENTS.md` is the canonical environment inventory and `docs/ARCHITECTURE.md` describes trust boundaries and data flow.

## Router baseline

- Device: PoliceDBC MikroTik RB4011iGS+.
- RouterOS baseline: 7.24.2+.
- WAN: `ether1 = 192.168.205.251/21`.
- Upstream gateway: `192.168.200.1`.
- LAN: `bridge-lan = 192.168.1.1/24`.
- DHCP pool: `192.168.1.50-192.168.1.199`.
- WireGuard: `wg-remote = 10.8.0.1/24`, UDP 51820.
- CORE WireGuard peer: `10.8.0.2/32`.

## CORE contract

~~~text
physical interface: ens33
WireGuard interface: policedbc
default route:      via 192.168.1.1 on ens33
physical LAN:       192.168.1.0/24 on ens33
WireGuard network:  10.8.0.0/24 on policedbc
~~~

CORE receives its LAN address dynamically. A currently observed DHCP address must not be promoted into a permanent topology invariant without an explicit addressing decision.

## Identity model

`zeazdev` is the desired automation SSH identity in the topology contract. Existing hosts may be administered during recovery by another local account. Scripts must use the actual selected account rather than assuming the desired automation identity already exists.

## Legacy warning

The old clean-slate PPPoE / `192.168.10.0/24` / alternate-WireGuard design is historical and incompatible with the current PoliceDBC production baseline.
