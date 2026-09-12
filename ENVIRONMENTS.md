# ZeaZDev Environment Inventory

## Environment map

| Environment | Endpoint | Desired automation identity | Runtime-address policy |
|---|---|---|---|
| DEV/controller | `core.zeaz.dev` | `zeazdev` | LAN is DHCP/runtime evidence; WG peer `10.8.0.2/32` is known |
| PROD | `prod.zeaz.dev` | `zeazdev` | LAN/WG addresses remain unset until verified |

The desired automation identity is a target configuration, not proof that the account already exists on every host. Existing operator/recovery accounts are valid when explicitly selected and secured.

## Router relationship

PoliceDBC provides the production LAN/WAN/VPN edge:

- RB4011iGS+;
- RouterOS 7.24.2+ baseline;
- WAN `192.168.205.251/21` on `ether1`;
- upstream `192.168.200.1`;
- LAN `192.168.1.1/24` on `bridge-lan`;
- DHCP pool `192.168.1.50-192.168.1.199`;
- WireGuard `wg-remote = 10.8.0.1/24`, UDP 51820;
- CORE peer `10.8.0.2/32`.

## DEV/CORE invariant

~~~text
default via 192.168.1.1 dev ens33
192.168.1.0/24 dev ens33
10.8.0.0/24 dev policedbc
~~~

`192.168.1.0/24` must not be present in active `policedbc` WireGuard `AllowedIPs`. Retained backup files may contain historical values but do not define active state.

## Address certainty

`config/topology.env.example` is a contract/template, not runtime evidence. DEV LAN addressing is intentionally not hard-coded because DHCP may change it. `PROD_LAN_IP` and `PROD_WG_IP` remain empty until independently verified.

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
