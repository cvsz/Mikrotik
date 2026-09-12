# CORE Network Recovery

## Known failure mode

CORE can lose reliable LAN/SSH reachability when the physical LAN `192.168.1.0/24` is installed through `policedbc` instead of `ens33`, or when the physical interface loses carrier.

## Required invariant

~~~text
default via 192.168.1.1 dev ens33
192.168.1.0/24 dev ens33
10.8.0.0/24 dev policedbc
~~~

## Diagnose first

~~~bash
make core-status
make core-check
ip route get 192.168.1.1
ip route
sudo wg show policedbc
~~~

If `ens33` has no carrier, repair the VMware/physical network path before changing routes.

## Runtime repair

`make core-repair` removes only the conflicting runtime LAN route from the WireGuard interface and refreshes the physical interface. It deliberately does not rewrite persistent network configuration.

## Persistent repair

Inspect active WireGuard configuration:

~~~bash
make core-find-conflict
sudo grep -nE '^[[:space:]]*AllowedIPs[[:space:]]*=' /etc/wireguard/*.conf
~~~

Active `policedbc` configuration should route only the intended WireGuard network. Backup files may retain the previous line for rollback and are not active configuration.

After editing a persistent WireGuard config, prefer an in-place `wg syncconf` path where appropriate rather than dropping the management tunnel blindly.

## Acceptance

1. `make core-check` passes;
2. `make core-find-conflict` passes;
3. gateway and internet route decisions use `ens33`;
4. WireGuard handshake is current;
5. SSH key-only login works from another LAN host;
6. reboot CORE;
7. repeat checks after reboot.

Do not claim persistent recovery until post-reboot verification passes.
