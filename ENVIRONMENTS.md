# ZeaZDev Environment Inventory

## Environment map

| Environment | Endpoint | Desired automation identity | Runtime-address policy |
|---|---|---|---|
| DEV/controller | `core.zeaz.dev` | `zeazdev` | LAN target `192.168.1.123`; DHCP binding waits for verified MAC; WG peer `10.8.0.2/32` is known |
| PROD | `prod.zeaz.dev` | `zeazdev` | LAN `192.168.1.122`, MAC `00:0C:29:B5:F4:09` verified; WG remains unset until verified |
| HA-A | `ha-a.zeaz.dev` | system host identity | LAN `192.168.1.119`, MAC `00:0C:29:B7:22:AF` verified |
| HA-B | `ha-b.zeaz.dev` | system host identity | LAN `192.168.1.120`, MAC `00:0C:29:72:EF:42` verified |
| PoliceDBC-SEA | `PoliceDBC-SEA` | Windows host | LAN `192.168.1.100`, MAC `48:4D:7E:D4:3A:C6` verified |
| CI runner VM | `zeaz` | `zOS-Runner` | Windows x64; trusted GitHub Actions execution surface only |

The desired automation identity is a target configuration, not proof that the account already exists on every host. Existing operator/recovery accounts are valid when explicitly selected and secured.

## Windows runner VM

The separate Windows VM `zeaz` hosts the repository-scoped self-hosted runner:

~~~text
runner name:    zOS-Runner
root:           D:\zOS-Runner
scheduled task: zOS-GitHub-Runner
labels:         self-hosted, Windows, X64
~~~

Its configuration template is `runner/.env.example`. This VM is not a source of RouterOS topology truth and must not receive ordinary live-production mutation authority.

## Router relationship

PoliceDBC provides the production LAN/WAN/VPN edge:

- MikroTik RB4011iGS+;
- RouterOS 7.24.2+ baseline;
- WAN is DHCP client on `ether1`; the observed lease `192.168.202.91/21` is runtime evidence, not a hard-coded invariant;
- upstream gateway observed from DHCP: `192.168.200.1`;
- LAN `192.168.1.1/24` on `bridgeLocal`;
- `ether2`-`ether10` and `sfp-sfpplus1` are LAN bridge ports;
- DHCP dynamic pool excludes fixed infrastructure addresses `.100`, `.119`, `.120`, `.122`, `.123`;
- WireGuard target remains `wg-remote = 10.8.0.1/24`, UDP 51820;
- CORE peer target `10.8.0.2/32`.

## DEV/CORE invariant

~~~text
default via 192.168.1.1 dev ens33
192.168.1.0/24 dev ens33
10.8.0.0/24 dev policedbc
~~~

`192.168.1.0/24` must not be present in active `policedbc` WireGuard `AllowedIPs`.

## Address certainty

`config/topology.env.example` is the desired topology contract. `core.zeaz.dev = 192.168.1.123` is reserved in DNS and excluded from the dynamic DHCP pool, but its static DHCP lease must not be created until the CORE MAC address is verified. The other listed fixed hosts have verified MAC/IP pairs.

## Future overlay design

Reserved design target only:

~~~text
10.77.0.0/24
CORE   10.77.0.21
PROD   10.77.0.11
HA-A   10.77.0.31
HA-B   10.77.0.32
UDP    51820
~~~

This is not evidence that the overlay has been deployed.

## k3s separation

Planned cluster ranges must be validated against real routing before use:

~~~text
DEV  pods 10.52.0.0/16
DEV  services 10.53.0.0/16
PROD pods 10.42.0.0/16
PROD services 10.43.0.0/16
~~~
