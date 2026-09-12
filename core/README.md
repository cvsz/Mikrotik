# CORE SSH bootstrap

`core/install.sh` is the recovery/bootstrap path for the canonical DEV/CORE Ubuntu host.

It is designed for the known route conflict where the physical LAN `192.168.1.0/24` is incorrectly installed through `policedbc` instead of `ens33`, which can make SSH unreachable even when `sshd` is healthy.

## Production-safe defaults

```text
LAN_IFACE=ens33
WG_IFACE=policedbc
LAN_CIDR=192.168.1.0/24
GW=192.168.1.1
SSH_PORT=22
SSH_ALLOW_PASSWORD=no
```

Password authentication is fail-closed by default. The installer refuses to disable password login unless the selected SSH user already has a non-empty `~/.ssh/authorized_keys` file.

Normal production path:

```bash
sudo ./core/install.sh
```

If this is a recovery/bootstrap situation and no public key has been installed yet, password login must be explicitly opted into for that run:

```bash
sudo SSH_ALLOW_PASSWORD=yes ./core/install.sh
```

After public-key login is proven, rerun with the default or explicitly set:

```bash
sudo SSH_ALLOW_PASSWORD=no ./core/install.sh
```

Override other values with environment variables only when the host genuinely differs:

```bash
sudo LAN_IFACE=ens33 SSH_USER=zeazdev SSH_PORT=22 ./core/install.sh
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

Do not run `git pull` from a root shell in a user-owned repository. Update as the repository owner, then run the installer with privilege.

Example:

```bash
cd /home/cvsz/zos
git pull --ff-only origin main
sudo ./core/install.sh
```

If you must remain in a root shell, execute Git as the repository owner instead of adding a broad `safe.directory` exception.

## HashiCorp APT signing-key recovery

If `apt-get update` fails on `apt.releases.hashicorp.com` because the signing key is missing or stale, the installer follows a fail-closed signed-repository recovery path:

- downloads the key only from `https://apt.releases.hashicorp.com/gpg`;
- parses it as OpenPGP key material;
- verifies the primary fingerprint is exactly `D55C 0D1A C78A 8D81 26CB 631C FC9C A96A CA02 6560`;
- refuses installation on any fingerprint mismatch;
- installs it at `/usr/share/keyrings/hashicorp-archive-keyring.gpg` only after verification;
- preserves a correctly configured `signed-by` source;
- backs up and normalizes `/etc/apt/sources.list.d/hashicorp.list` only when needed;
- retries `apt-get update` without bypassing APT signature checks.

The fingerprint is intentionally pinned in source. A future HashiCorp key rotation must be reviewed and updated in the repository rather than silently trusted at runtime.

If APT fails for another repository or another cause, the installer stops instead of disabling security controls.
