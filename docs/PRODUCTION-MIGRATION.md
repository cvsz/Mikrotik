# Production Migration

This document records the migration from the historical clean-slate design to the current PoliceDBC production baseline.

## Current naming

- DEV/controller: `core.zeaz.dev`;
- PROD: `prod.zeaz.dev`;
- desired automation identity: `zeazdev` (do not assume it already exists on an existing host).

## Current router baseline

- WAN `192.168.205.251/21`;
- upstream gateway `192.168.200.1`;
- LAN `192.168.1.1/24`;
- WireGuard `wg-remote = 10.8.0.1/24`;
- CORE peer `10.8.0.2/32`.

## Deprecated assumptions

The old PPPoE / `192.168.10.0/24` / alternate WireGuard clean-slate design must not be applied to the current production router.

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

Every migration step remains subject to backup, dry-run, recovery/Safe Mode, explicit live-apply approval, and post-change verification.

## Production host addressing

Verified PROD LAN address:

~~~text
prod.zeaz.dev -> 192.168.1.122
~~~

`PROD_WG_IP` remains unknown and must not be populated until independently observed. Migration documentation must not turn design targets into claims of deployed state.
