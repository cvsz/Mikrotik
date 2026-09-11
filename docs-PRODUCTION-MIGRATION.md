# Production migration notes

Historical assumptions:
- reset/clean-slate router
- PPPoE WAN
- LAN 192.168.10.0/24
- new wg-admin 10.99.0.0/24

PoliceDBC production:
- WAN 192.168.205.251/21
- gateway 192.168.200.1
- LAN 192.168.1.0/24
- existing wg-remote 10.8.0.1/24
- L2TP/IPsec may still be required

The old zeaz-meta-master-oneclick.rsc must not be applied to PoliceDBC.

Recommended sequence:
```
/import file-name=00-PRECHECK.rsc verbose=yes dry-run
/import file-name=10-BACKUP-SNAPSHOT.rsc verbose=yes dry-run
/import file-name=20-NETWORK-NORMALIZE.rsc verbose=yes dry-run
/import file-name=30-DHCP-DNS-NTP.rsc verbose=yes dry-run
/import file-name=40-WIREGUARD-SERVICES.rsc verbose=yes dry-run
/import file-name=99-VERIFY-HEALTH.rsc verbose=yes dry-run
```

Only apply after successful dry-run and while in Safe Mode.
