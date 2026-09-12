---
name: routeros-fundamentals
description: "RouterOS v7 domain knowledge for AI agents. Use when: working with MikroTik RouterOS, writing RouterOS CLI/script commands, calling RouterOS REST API, debugging why a Linux command fails on RouterOS, or when the user mentions MikroTik, RouterOS, CHR, or /ip /system /interface paths. Scope: RouterOS 7.x only."
---

# RouterOS Fundamentals

## RouterOS Is Not GNU/Linux

RouterOS uses its own CLI, configuration database, scripting language, REST API, package system, and service model. Do not assume normal Linux userland behavior.

What is not available in the normal RouterOS CLI environment:

- no `/bin`, `/usr`, `/etc`, or `/var` FHS workflow;
- no bash/sh/coreutils workflow;
- no apt/opkg package manager;
- no systemd/service manager;
- no ordinary Linux `/proc` or `/sys` administration workflow;
- no Docker/Podman command surface; RouterOS uses its own `/container` subsystem.

What is available:

- RouterOS CLI over SSH, serial, WinBox, or WebFig;
- REST API under `/rest/`;
- RouterOS `.rsc` scripting;
- WebFig and WinBox management;
- RouterOS packages and built-in subsystems.

See the [Scripting reference](./references/scripting.md) and the `routeros-scripting` skill for language details.

## Common Agent Mistakes

- Do not run Linux shell commands such as `ls`, `mount`, `fdisk`, `iptables`, or `systemctl` on RouterOS.
- Do not look for configuration files under `/etc`.
- Do not assume shell pipes, redirection, or subshell syntax.
- Do not suggest `apt` or `opkg`; RouterOS packages are `.npk` files.
- Do not use production addresses in generic examples.
- Do not treat interactive print-row numbers as stable script identifiers.

See [Extra packages reference](./references/extra-packages.md) for package patterns.

## RouterOS CLI Syntax

RouterOS uses path-based commands:

```routeros
# Navigation
/ip/address/print
/interface/print
/system/resource/print

# Safe fictional example network; do not copy production addresses into tutorials
/ip/address/add address=198.51.100.1/24 interface=bridge-lab

# Modify using a stable find expression
/ip/address/set [find interface=bridge-lab] address=198.51.100.2/24

# Remove by an explicit fictional address
/ip/address/remove [find address="198.51.100.2/24"]
```

The `198.51.100.0/24` block above is documentation-only. On the ZeaZDev PoliceDBC router, the production LAN gateway belongs on `bridge-lan`; never use a generic example to move it onto `ether1`.

Key syntax rules:

- `=` assigns properties;
- `[find ...]` queries objects;
- interactive row numbers are not script-safe IDs;
- internal IDs look like `*HEX` but should be looked up instead of hard-coded where practical;
- strings use double quotes;
- comments use `#`;
- variables use RouterOS syntax such as `:local name "value"`;
- there are no shell pipes/redirections/subshells.

## REST API

RouterOS REST commonly maps verbs as follows:

| HTTP | RouterOS action | CLI equivalent |
|---|---|---|
| `GET` | print/read | `/path/print` |
| `PUT` | add/create | `/path/add` |
| `PATCH` | set/update | `/path/set` |
| `DELETE` | remove | `/path/remove` |
| `POST` | command/action | `/path/command` |

Important points:

- `PUT` creates; it is not the normal REST-update semantic.
- REST endpoints require authentication.
- `.id` values are RouterOS internal identifiers and should be looked up when used.
- A synchronous `/rest/execute` request can return HTTP 200 even when RouterOS rejects the command. HTTP status alone is therefore not proof of effect; inspect the returned payload and verify resulting state independently.

See [REST API reference](./references/rest-api-patterns.md).

## Version Scheme

RouterOS 7 versions use forms such as `7.22`, `7.22.1`, `7.23beta2`, and `7.22rc1`.

Common channels include `stable`, `long-term`, `testing`, and `development`.

See [Version parsing reference](./references/version-parsing.md).

## Architecture Names

| MikroTik name | General architecture | Example use |
|---|---|---|
| `x86` | x86_64 | CHR/x86 systems |
| `arm64` | aarch64 | modern ARM64 boards |
| `arm` | ARMv7 | older ARM boards |
| `mipsbe` | MIPS big-endian | legacy RouterBOARDs |
| `mmips` | MIPS multi-core | devices such as RB4011 |
| `smips` | MIPS single-core | smaller legacy boards |
| `ppc` | PowerPC | older CCR families |
| `tile` | Tilera | older CCR families |

Always verify the architecture from the real device before selecting packages.

## Default/Initial Credentials

Fresh-device credential behavior varies with device generation, factory state, and RouterOS packaging. Do not assume an empty password on production equipment. Inspect the actual device onboarding state and immediately use a strong unique credential policy.

## Hardware and Service Inspection

```routeros
/system/resource/hardware/print
/system/resource/irq/print
/system/resource/print
/disk/print
/system/package/print
/ip/service/print
/interface/print
```

## References

Local reference targets are kept valid in this vendored skill pack. Some files are provenance pointers to the canonical upstream `tikoci/routeros-skills` reference until full reference content is synchronized.

- [REST API reference](./references/rest-api-patterns.md)
- [Version parsing reference](./references/version-parsing.md)
- [Extra packages reference](./references/extra-packages.md)
- [Device-mode reference](./references/device-mode.md)
- [Device-mode REST reference](./references/device-mode-rest.md)
- [RouterOS scripting reference](./references/scripting.md)
- [Users REST reference](./references/routeros-users-rest.md)
- [Networking REST reference](./references/routeros-networking-rest.md)
- [Firewall REST reference](./references/routeros-firewall-rest.md)
- [Packages REST reference](./references/packages-rest.md)
- [Licensing REST reference](./references/licensing-rest.md)
- [Async commands REST reference](./references/async-commands-rest.md)
- [Bun runtime gotchas](./references/bun-runtime-gotchas.md)

Official documentation: <https://manual.mikrotik.com/>

## Related Skills

- `routeros-scripting`
- `routeros-container`
- `routeros-netinstall`
- `routeros-app-yaml`
- `routeros-command-tree`
- `routeros-qemu-chr`
- `routeros-sniffer`
