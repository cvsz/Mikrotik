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


## Update the repository without Git ownership errors

The working tree at `/home/cvsz/zos` is owned by the normal `cvsz` account. Do not run `git pull` from a root shell in that user-owned repository. Git correctly rejects that as dubious ownership.

Preferred flow:

```bash
exit                         # leave the root shell, if currently root
cd /home/cvsz/zos
git pull --ff-only origin main
sudo ./core/install.sh
```

If you must remain in a root shell, execute Git as the repository owner instead of adding a global `safe.directory` exception:

```bash
sudo -u cvsz git -C /home/cvsz/zos pull --ff-only origin main
./core/install.sh
```

## HashiCorp APT signing-key recovery

If `apt-get update` fails on `apt.releases.hashicorp.com` with `NO_PUBKEY` or a stale signing key, the installer now follows HashiCorp's signed-repository model:

- downloads the signing key only from `https://apt.releases.hashicorp.com/gpg`;
- validates that the download is OpenPGP public-key material;
- installs it at `/usr/share/keyrings/hashicorp-archive-keyring.gpg`;
- preserves a correctly configured `signed-by` source;
- backs up and normalizes the common `/etc/apt/sources.list.d/hashicorp.list` only when it lacks `signed-by`;
- retries `apt-get update`;
- never uses `trusted=yes`, `--allow-unauthenticated`, or an APT signature bypass.

If APT fails for a different repository or a different cause, the installer stops instead of silently disabling security checks.
