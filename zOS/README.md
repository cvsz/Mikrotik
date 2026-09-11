# zOS for MikroTik

zOS is the ZeaZDev control-plane and automation layer for MikroTik RouterOS.

It does **not** replace RouterOS firmware. RouterOS remains the trusted network operating system on the RB4011; zOS runs on `core.zeaz.dev` and controls the router through SSH/API-compatible workflows with audit, backup, dry-run, Safe Mode, verification and rollback gates.

## Canonical topology

- DEV/controller: `core.zeaz.dev`, user `zeazdev`
- PROD: `prod.zeaz.dev`, user `zeazdev`
- Router: PoliceDBC RB4011iGS+, RouterOS 7.24.2+
- Router LAN: `192.168.1.1/24`
- Router WAN: `192.168.205.251/21`
- Upstream: `192.168.200.1`
- WireGuard: `wg-remote`, router `10.8.0.1/24`, CORE peer `10.8.0.2/32`

## zOS layers

1. **Inventory** — canonical topology and environment data.
2. **Observe** — status, audit, logs, package/update state and evidence export.
3. **Plan** — deterministic RouterOS phase files and change plans.
4. **Validate** — topology checks, destructive-pattern blocking and shell validation.
5. **Protect** — backup/export, Safe Mode requirement and explicit live-apply gates.
6. **Apply** — idempotent RouterOS phases only.
7. **Verify** — WAN, LAN, DNS, WireGuard, management and DEV/PROD smoke tests.
8. **Update** — RouterOS update detection, server notification and optional guarded auto-install.
9. **Recover** — CORE route repair and disaster-recovery runbooks.

## Commands

```bash
./zOS/bin/zos doctor
./zOS/bin/zos status
./zOS/bin/zos audit
./zOS/bin/zos backup
./zOS/bin/zos plan
./zOS/bin/zos verify
./zOS/bin/zos update-check
./zOS/bin/zos update-notify
./zOS/bin/zos update-auto
./zOS/bin/zos e2e
```

Live RouterOS changes remain disabled unless the existing OMEGA safety gates are explicitly enabled.
