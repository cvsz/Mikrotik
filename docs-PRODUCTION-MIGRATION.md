# Real ZeaZDev DEV/PROD migration notes

## Canonical naming
- DEV = `core.zeaz.dev`
- PROD = `prod.zeaz.dev`
- SSH user = `zeazdev`

Legacy names such as DBC must not be used in new scripts or documentation.

## Router baseline
PoliceDBC production uses:
- WAN 192.168.205.251/21
- gateway 192.168.200.1
- LAN 192.168.1.0/24
- existing wg-remote 10.8.0.1/24
- DEV/CORE peer 10.8.0.2/32

The old clean-slate PPPoE / 192.168.10.0 / wg-admin 10.99.0.0 design is incompatible with the real deployment.

Recommended apply sequence remains:
```
/import file-name=00-PRECHECK.rsc verbose=yes dry-run
/import file-name=10-BACKUP-SNAPSHOT.rsc verbose=yes dry-run
/import file-name=20-NETWORK-NORMALIZE.rsc verbose=yes dry-run
/import file-name=30-DHCP-DNS-NTP.rsc verbose=yes dry-run
/import file-name=40-WIREGUARD-SERVICES.rsc verbose=yes dry-run
/import file-name=50-FIREWALL-NAT.rsc verbose=yes dry-run
/import file-name=99-VERIFY-HEALTH.rsc verbose=yes dry-run
```
