# Production Migration

This document records the migration from the historical clean-slate design to the current PoliceDBC production baseline.

## Current naming

- DEV/controller: `core.zeaz.dev`;
- PROD: `prod.zeaz.dev`;
- desired automation identity: `zeazdev` (do not assume it already exists on an existing host).

## Current router baseline

- WAN: DHCP client on `ether1`;
- observed WAN lease: `192.168.202.91/21` (runtime evidence only, never hard-code it);
- upstream gateway observed from DHCP: `192.168.200.1`;
- LAN: `bridgeLocal = 192.168.1.1/24`;
- LAN ports: `ether2`-`ether10` and `sfp-sfpplus1`;
- NAT: `192.168.1.0/24 -> WAN`;
- WireGuard target: `wg-remote = 10.8.0.1/24`;
- CORE peer target: `10.8.0.2/32`.

## Fixed LAN inventory

~~~text
PoliceDBC-SEA  192.168.1.100  48:4D:7E:D4:3A:C6
ha-a.zeaz.dev  192.168.1.119  00:0C:29:B7:22:AF
ha-b.zeaz.dev  192.168.1.120  00:0C:29:72:EF:42
prod.zeaz.dev  192.168.1.122  00:0C:29:B5:F4:09
core.zeaz.dev  192.168.1.123  MAC pending verification
~~~

`192.168.1.123` is reserved from the dynamic pool and has local DNS, but CORE must not receive a static DHCP binding until its MAC address is independently verified.

## Deprecated assumptions

The old static-WAN `192.168.205.251/21`, `bridge-lan`, PPPoE, `192.168.10.0/24`, old CORE `.128`, and alternate WireGuard clean-slate assumptions must not be applied to the current production router.

## Active phase sequence

~~~text
00-PRECHECK.rsc
10-BACKUP-SNAPSHOT.rsc
20-NETWORK-NORMALIZE.rsc
30-DHCP-DNS-NTP.rsc
40-WIREGUARD-SERVICES.rsc
50-FIREWALL-NAT.rsc
60-OBSERVABILITY.rsc
90-EXPORT-EVIDENCE.rsc
99-VERIFY-HEALTH.rsc
~~~

For a clean RouterOS rebuild, use `reinstall/OMEGA-RB4011-GOLDEN-REINSTALL.rsc` through an operator-controlled recovery path.

Every migration step remains subject to backup, dry-run, recovery/Safe Mode, explicit live-apply approval, and post-change verification.

`PROD_WG_IP` remains unknown and must not be populated until independently observed. Migration documentation must not turn design targets into claims of deployed state.
