---
name: routeros-netinstall
description: "MikroTik netinstall-cli for RouterOS device recovery/reinstallation. Use when: automating Netinstall, writing scripts that invoke netinstall-cli, working with etherboot/BOOTP/TFTP, RouterOS .npk packages, mode scripts, configure scripts, or device flashing."
---

# RouterOS Netinstall

Netinstall is a destructive recovery/reinstallation mechanism. It reformats the RouterOS system drive and must not be treated as an ordinary package upgrade path.

## Production Safety Rule

For ZeaZDev production hardware, including PoliceDBC:

1. audit the device and verify identity/MAC/architecture;
2. confirm a local recovery-capable management path;
3. export configuration and create a trusted backup;
4. preserve required keys/credentials and record current RouterBOOT/device-mode state;
5. disconnect the device from unrelated production Layer-2 segments where practical;
6. do not use `-e` unless the target is explicitly disposable/lab hardware or the operator has approved an intentional empty-configuration rebuild;
7. verify restored management, WAN/LAN, firewall/NAT, DHCP/DNS, and WireGuard state after reinstall.

**Never run an empty-config Netinstall recipe against PoliceDBC production hardware as a convenience step.** `-e` intentionally removes the current RouterOS configuration after reformatting and can eliminate management access.

## What `netinstall-cli` Does

Netinstall reinstalls RouterOS on a device booted into etherboot mode. The Linux CLI listens for the device, sends the boot image, and installs the selected RouterOS packages.

Grounded operational properties:

- the system drive is reformatted;
- the RouterOS license key is not normally erased by the reformat;
- RouterBOOT settings are distinct from the RouterOS configuration database;
- Netinstall operates over a direct Layer-2 path using BOOTP/DHCP/TFTP behavior;
- root/sudo privileges are required on Linux.

## Command Syntax

```text
netinstall-cli [-r] [-e] [-b] [-m [-o]] [-f] [-v] [-c]
               [-k <keyfile>] [-s <userscript>] [-sm <modescript>]
               [--mac <mac>] {-i <interface> | -a <client-ip>} [PACKAGES...]
```

## Important Flags

| Flag | Meaning / risk |
|---|---|
| `-r` | reinstall and run the default-configuration stage |
| `-e` | reinstall with empty configuration; destructive to current config |
| `-b` | discard installed branding package |
| `-m` | repeated/multi-device install mode |
| `-o` | with `-m`, only reinstall a MAC once per run |
| `-f` | ignore storage-size checks; use only when understood |
| `-v` | verbose output |
| `-c` | allow multiple Netinstall instances |
| `-k <keyfile>` | install a license key |
| `-s <userscript>` | install persistent custom/default configuration script |
| `-sm <modescript>` | install a one-time first-boot mode script |
| `--mac <mac>` | limit response to the intended device MAC |
| `-i <interface>` | bind to a specific host interface |
| `-a <client-ip>` | assign a specific client IP |

## Hard Rules

1. Put the RouterOS system package first in the package list.
2. Verify package architecture against the actual device.
3. Use a dedicated Layer-2 path and avoid competing DHCP/BOOTP services.
4. Prefer `--mac` when practical to prevent accidental selection of another device.
5. No `-r` and no `-e` means Netinstall attempts to preserve the configuration database, but this does not preserve every file/database stored on the device.
6. Treat `-e` as an intentional reset/rebuild operation, not a standard reinstall option.

## Install Workflow

1. Identify and back up the device.
2. Isolate/prepare the Netinstall network.
3. Put the device into etherboot mode.
4. Run Netinstall with the intended package set and explicit MAC/interface targeting.
5. Allow first-boot scripts to complete.
6. Reconnect only after management and policy verification.
7. Restore/verify production-specific configuration from trusted evidence as required.

## Configure Script vs Mode Script

| Feature | Configure script (`-s`) | Mode script (`-sm`) |
|---|---|---|
| Purpose | replace supplied default configuration stage | one-time first-boot actions before config stage |
| Persistence | retained as custom default configuration | removed after execution |
| Reset behavior | can run again after later reset | does not persist for later resets |
| Typical use | deterministic baseline configuration | early device-mode / boot-state actions |

If a mode script changes device-mode and forces a reboot, design the sequence so subsequent configuration remains deterministic and recoverable.

## Package URL Pattern

```text
https://download.mikrotik.com/routeros/{version}/routeros-{version}-{arch}.npk
https://download.mikrotik.com/routeros/{version}/all_packages-{arch}-{version}.zip
https://download.mikrotik.com/routeros/{version}/netinstall-{version}.tar.gz
```

Use MikroTik's official download source and verify the selected version and architecture before installation.

## Example: Lab Reinstall With Default Configuration

The following is a lab example only; replace the interface, package, version, and architecture after verification:

```sh
sudo ./netinstall-cli -r --mac 02:00:00:00:00:10 -i lab0 \
  routeros-7.22-arm64.npk
```

The MAC/interface values are intentionally fictional placeholders.

## Empty Configuration — Disposable/Lab Devices Only

`-e` requests an empty configuration after reinstall. It is appropriate only when the operator explicitly wants a clean rebuild and has accepted the loss of the current configuration.

```sh
# LAB / DISPOSABLE TARGET ONLY
sudo ./netinstall-cli -e --mac 02:00:00:00:00:10 -i lab0 \
  routeros-7.22-arm64.npk
```

Before adapting this example to any real device, complete the production safety checklist above. Do not use this pattern on PoliceDBC unless an approved disaster-recovery rebuild specifically requires it.

## Keep Existing Configuration Database

When the operational goal is reinstalling while attempting to retain the RouterOS configuration database, omit both `-r` and `-e`:

```sh
sudo ./netinstall-cli --mac 02:00:00:00:00:10 -i lab0 \
  routeros-7.22-arm64.npk
```

This still reformats the system drive and does not guarantee preservation of unrelated user files/databases.

## Etherboot Notes

Common entry methods include the reset button, serial console, or a one-time Ethernet boot setting. Netinstall can fail when another DHCP source is present, when DHCP snooping blocks the path, or when an adapter causes link flaps.

## Non-x86 Hosts

When the official Linux Netinstall binary is not native to the host architecture, use a supported compatibility/VM approach and ensure the Netinstall interface is bridged at Layer 2. Do not add unnecessary translation layers on a production recovery path.

## References

- Official MikroTik Netinstall documentation: <https://manual.mikrotik.com/>
- Version/channel patterns: [RouterOS version parsing reference](../routeros-fundamentals/references/version-parsing.md)
- Upstream wrapper/example project: <https://github.com/tikoci/netinstall>

## ZeaZDev Production Invariant

Netinstall is a recovery/rebuild tool. It is not part of the normal zOS production apply pipeline. zOS production changes continue to use audit, backup, dry-run, recovery access/Safe Mode where appropriate, explicit operator gates, and post-change verification.
