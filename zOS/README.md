# zOS Controller Package

zOS is the controller-side ZeaZDev management/safety layer for MikroTik RouterOS. RouterOS remains the network operating system on the RB4011.

## Safety model

- observe before mutate;
- backup and dry-run before live apply;
- preserve management/recovery access;
- fail closed on unknown trust/topology;
- keep live apply explicitly gated;
- independently verify important outcomes.

## Commands

~~~bash
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
~~~

## Documentation

Start with `../docs/INDEX.md`, `../docs/ARCHITECTURE.md`, `../docs/zOS.md`, and `../docs/RUNBOOK.md`.

## Package

GitHub Actions builds a tarball/checksum and controller-side OCI image `ghcr.io/cvsz/mikrotik-zos`. The image is not RouterOS firmware.
