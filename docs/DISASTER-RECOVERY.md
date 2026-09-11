# Disaster Recovery

## Recovery priorities

1. Preserve or regain local/MAC/console management.
2. Restore `bridge-lan` and `192.168.1.1/24` LAN management.
3. Restore WAN `192.168.205.251/21` and default gateway `192.168.200.1`.
4. Restore DHCP/DNS.
5. Restore WireGuard while preserving the known key material from a trusted backup.
6. Verify firewall/NAT and then application connectivity.

## Safe Mode rollback

For risky live work, enter RouterOS Safe Mode before applying changes. If management is lost and the Safe Mode session terminates abnormally, RouterOS should roll back the Safe Mode changes. Do not deliberately rely on Safe Mode as a substitute for backups.

## Text export recovery

The controller downloads pre-change exports into `backups/`. Review before importing because exports can contain configuration that should not be blindly restored over a changed topology.

## Binary backup recovery

`10-BACKUP-SNAPSHOT.rsc` and `make backup` create binary `.backup` files on the router. Binary restores are device/configuration-sensitive and should be treated as last-resort full-state recovery.

## Minimal emergency validation

After recovery:

```text
/ip address print
/ip route print where dst-address=0.0.0.0/0
/interface bridge port print
/ip dhcp-server print detail
/interface wireguard print detail
/interface wireguard peers print detail
/ip service print
/ping 192.168.200.1 count=3
/ping 1.1.1.1 count=3
:put [/resolve cloudflare.com]
```

From DEV/CORE also validate that `192.168.1.0/24` routes through `ens33`, not the `policedbc` WireGuard interface.
