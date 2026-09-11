# ZeaZDev Environment Inventory

| Environment | FQDN | SSH user | Purpose |
|---|---|---|---|
| DEV | core.zeaz.dev | zeazdev | Development / automation / Codex controller |
| PRODUCTION | prod.zeaz.dev | zeazdev | Production workload host |

## Router relationship
PoliceDBC provides LAN/WAN/VPN connectivity. Current router-side WireGuard peer for DEV/CORE is `10.8.0.2/32`.

Do not assume PROD shares the same host/IP as DEV. Keep DEV and PROD logically and operationally separate.
