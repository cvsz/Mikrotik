# CORE SSH bootstrap

`core/install.sh` is the recovery/bootstrap path for the canonical DEV/CORE Ubuntu host.

It is designed for the known route conflict where the physical LAN `192.168.1.0/24` is incorrectly installed through `policedbc` instead of `ens33`, which can make SSH unreachable even when `sshd` is healthy.

## Run

```bash
sudo ./core/install.sh
```

Defaults:

```text
LAN_IFACE=ens33
WG_IFACE=policedbc
LAN_CIDR=192.168.1.0/24
GW=192.168.1.1
SSH_PORT=22
SSH_ALLOW_PASSWORD=yes
```

Override values with environment variables when the host differs:

```bash
sudo LAN_IFACE=ens33 SSH_USER=zeazdev SSH_PORT=22 ./core/install.sh
```

After SSH public-key login is confirmed, disable password login:

```bash
sudo SSH_ALLOW_PASSWORD=no ./core/install.sh
```

The installer intentionally does **not** rewrite persistent WireGuard, Netplan, NetworkManager, Docker, or systemd-networkd configuration. It removes only the conflicting runtime LAN route from `policedbc`, validates that the gateway resolves through `ens33`, installs/enables OpenSSH, validates `sshd`, and opens the SSH port only when UFW is already active.

Expected CORE routing:

```text
default via 192.168.1.1 dev ens33
192.168.1.0/24 dev ens33
10.8.0.0/24 dev policedbc
```

The physical LAN must not be present in the WireGuard `AllowedIPs` for `policedbc`.
