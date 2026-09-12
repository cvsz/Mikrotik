# ZeaZDev Environment Inventory

## Canonical environment map

| Environment | FQDN | SSH user | Purpose |
|---|---|---|---|
| DEV | `core.zeaz.dev` | `zeazdev` | development, zOS controller, automation |
| PROD | `prod.zeaz.dev` | `zeazdev` | production workloads |

The old DBC hostname is historical only and must not be used in new automation.

## Router relationship

PoliceDBC provides LAN/WAN/VPN connectivity.

Current verified router baseline:

- MikroTik RB4011iGS+
- RouterOS `7.24.2`
- WAN: `192.168.205.251/21` on `ether1`
- Upstream gateway: `192.168.200.1`
- LAN: `192.168.1.1/24` on `bridge-lan`
- DHCP pool: `192.168.1.50-192.168.1.199`
- WireGuard: `wg-remote = 10.8.0.1/24`, UDP `51820`
- DEV/CORE peer: `10.8.0.2/32`

## DEV/CORE routing invariant

```text
default via 192.168.1.1 dev ens33
192.168.1.0/24 dev ens33
10.8.0.0/24 dev policedbc
```

The physical LAN `192.168.1.0/24` must not be installed through `policedbc`.

## PROD addressing

`PROD_LAN_IP` and `PROD_WG_IP` remain intentionally unset until observed from the real production host/router. Do not invent addresses in automation or documentation.

## Future overlay plan

Reserved design target:

```text
10.77.0.0/24
CORE   10.77.0.21
PROD   10.77.0.11
HA-A   10.77.0.31
HA-B   10.77.0.32
UDP    51820
```

This is a future design target, not evidence of an already deployed overlay.

## k3s separation

DEV and PROD remain separate clusters.

Planned ranges:

```text
DEV  pods 10.52.0.0/16
DEV  services 10.53.0.0/16
PROD pods 10.42.0.0/16
PROD services 10.43.0.0/16
```

Validate these ranges against real routes before deployment.
