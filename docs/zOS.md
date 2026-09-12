# zOS Operations

zOS is the ZeaZDev management/control layer for MikroTik RouterOS. It runs on `core.zeaz.dev`; RouterOS remains on the RB4011.

## Design goals

- fail closed;
- idempotent changes;
- audit and backup before mutation;
- dry-run before mutation;
- recovery access/Safe Mode for risky production work;
- explicit live-apply and reboot/update gates;
- auditable evidence;
- DEV/PROD separation;
- no secrets in source control.

## Install

```bash
chmod +x zOS/install.sh zOS/bin/zos tools/*.sh
./zOS/install.sh
zos doctor
```

## Daily/read-only operation

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
# Enter RouterOS Safe Mode manually from a recovery-capable session when appropriate.
export OMEGA_ALLOW_LIVE_APPLY=1
zos apply
zos verify
zos e2e
```

## RouterOS REST verification

A synchronous RouterOS `/rest/execute` request may return HTTP 200 even when the command is rejected. zOS integrations must validate response content and, for important changes, verify resulting state independently.

## RouterOS update automation

Safe default:

```env
ROUTEROS_UPDATE_CHANNEL=stable
OMEGA_AUTO_ROUTEROS_UPDATE=0
OMEGA_ALLOW_ROUTER_REBOOT=0
ROUTEROS_UPDATE_NOTIFY_URL=https://prod.zeaz.dev/api/infra/routeros-update
```

The notify URL is a configured target, not proof that an endpoint is deployed.

Unattended install requires both explicit gates:

```env
OMEGA_AUTO_ROUTEROS_UPDATE=1
OMEGA_ALLOW_ROUTER_REBOOT=1
```

The intended sequence is backup → pre-update verification → install/reboot → wait for return → post-update verification → report result.

## Package

The `build-zos` workflow produces:

- `zos-mikrotik-<version>.tar.gz`
- SHA-256 checksum
- multi-architecture OCI image `ghcr.io/cvsz/mikrotik-zos`

The image runs on the controller/server side; it is not RouterOS firmware.

## CI surfaces

- `validate-routeros-stack`: repository/static/safety validation
- `build-zos`: build/artifact/GHCR path
- `zOS RouterOS Skills Validation`: RouterOS skill validation on GitHub-hosted Windows
- optional manual self-hosted probe for `zOS-Runner`

The self-hosted runner must not be used as an implicit production apply channel.
