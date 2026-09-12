# zOS Operations

zOS is the ZeaZDev management layer for MikroTik RouterOS. It runs on `core.zeaz.dev`; RouterOS remains on the RB4011.

## Design goals

- fail closed
- idempotent RouterOS changes
- backup before mutation
- dry-run before mutation
- Safe Mode for production mutation
- explicit reboot/update gates
- auditable evidence after every change
- DEV and PROD separation

## Install

```bash
chmod +x zOS/install.sh zOS/bin/zos tools/*.sh
./zOS/install.sh
zos doctor
```

## Daily operation

```bash
zos status
zos audit
zos update-check
zos verify
```

## Planned change

```bash
zos backup
zos plan
# Enter RouterOS Safe Mode manually from a recovery-capable session.
export OMEGA_ALLOW_LIVE_APPLY=1
zos apply
zos verify
zos e2e
```

## RouterOS update automation

Safe default is notification-only:

```env
ROUTEROS_UPDATE_CHANNEL=stable
OMEGA_AUTO_ROUTEROS_UPDATE=0
OMEGA_ALLOW_ROUTER_REBOOT=0
ROUTEROS_UPDATE_NOTIFY_URL=https://prod.zeaz.dev/api/infra/routeros-update
```

Unattended installation is deliberately double-gated:

```env
OMEGA_AUTO_ROUTEROS_UPDATE=1
OMEGA_ALLOW_ROUTER_REBOOT=1
```

Before install, zOS creates a backup and runs health verification. RouterOS then performs its package install/reboot. zOS waits for the router to return and runs post-update verification, then reports the resulting version to the configured server endpoint.

## Package

The GitHub Actions `build-zos` workflow produces:

- `zos-mikrotik-<version>.tar.gz`
- SHA-256 checksum
- multi-architecture OCI image: `ghcr.io/cvsz/mikrotik-zos`

The OCI image is intended for the controller/server side, not as a replacement RouterOS firmware image.
