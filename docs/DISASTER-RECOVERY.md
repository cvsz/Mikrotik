# Disaster Recovery

## Recovery priorities

1. Preserve or regain local/MAC/console management.
2. Restore `bridge-lan` and `192.168.1.1/24`.
3. Restore WAN `192.168.205.251/21` and gateway `192.168.200.1`.
4. Restore DHCP/DNS.
5. Restore WireGuard using trusted known key material.
6. Verify firewall/NAT and then application connectivity.

## Safe Mode rollback

Use RouterOS Safe Mode for risky live production changes where appropriate. If management is lost and the Safe Mode session terminates abnormally, Safe Mode can roll back those changes. Safe Mode is not a substitute for backups.

## Text export recovery

Controller-side exports under `backups/` are evidence and recovery inputs. Review them before import; do not blindly restore an export over a topology that has intentionally changed.

## Binary backup recovery

Binary `.backup` files are device/configuration-sensitive and should be treated as last-resort full-state recovery. Protect them as sensitive material.

## CORE route recovery

After router recovery, also verify DEV/CORE:

```text
default via 192.168.1.1 dev ens33
192.168.1.0/24 dev ens33
10.8.0.0/24 dev policedbc
```

If the physical LAN is claimed by `policedbc`, repair the local route and remove the physical LAN from persistent WireGuard `AllowedIPs`.

## Self-hosted runner recovery

Runner location and launch model:

```text
D:\zOS-Runner
Scheduled Task: zOS-GitHub-Runner
```

If the listener is unhealthy:

```powershell
Stop-ScheduledTask -TaskName 'zOS-GitHub-Runner'
Get-Process Runner.Listener,Runner.Worker -ErrorAction SilentlyContinue | Stop-Process -Force
Start-ScheduledTask -TaskName 'zOS-GitHub-Runner'
```

Do not re-register the runner merely because a manually launched second `run.cmd` reports a session conflict.

## Minimal RouterOS validation

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
