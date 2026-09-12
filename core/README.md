# CORE SSH and Network Bootstrap

`core/install.sh` is the conservative recovery/bootstrap path for the DEV/CORE Ubuntu host. It is designed around the known failure mode where the physical LAN route can be incorrectly claimed by the `policedbc` WireGuard peer, making SSH unreachable even though sshd itself is healthy.

## Defaults

~~~text
LAN_IFACE=ens33
WG_IFACE=policedbc
LAN_CIDR=192.168.1.0/24
GW=192.168.1.1
SSH_PORT=22
SSH_ALLOW_PASSWORD=no
~~~

`SSH_USER` defaults to the invoking sudo user when available. This is intentional: the desired automation account (`zeazdev`) may not yet exist on an already-deployed host.

## Safe production path

1. update the repository as its owner;
2. keep the existing recovery terminal/session open;
3. ensure the intended SSH user has a valid public key;
4. run the installer with sudo;
5. verify key-only login from another host;
6. verify active WireGuard configuration and reboot persistence.

~~~bash
cd /home/<repo-owner>/zos
git pull --ff-only origin main
sudo ./core/install.sh
make core-check
make core-find-conflict
~~~

Do not run `git pull` as root inside a user-owned working tree and do not globally weaken Git `safe.directory` protections to work around ownership.

## SSH lockout prevention

Password authentication is disabled by default. Before writing a key-only sshd drop-in, the installer verifies that the selected SSH user exists, has a valid home directory, and has a non-empty `~/.ssh/authorized_keys` file.

If emergency password bootstrap is genuinely required, opt in explicitly for that run only:

~~~bash
sudo SSH_ALLOW_PASSWORD=yes ./core/install.sh
~~~

After a public-key login succeeds from another host, rerun with the secure default:

~~~bash
sudo SSH_ALLOW_PASSWORD=no ./core/install.sh
~~~

See `docs/SSH-HARDENING.md` for verification commands.

## Network contract

~~~text
default via 192.168.1.1 dev ens33
192.168.1.0/24 dev ens33
10.8.0.0/24 dev policedbc
~~~

The installer removes only an immediately conflicting runtime route. It does not rewrite persistent WireGuard, Netplan, NetworkManager, Docker, or systemd-networkd configuration.

`make core-find-conflict` evaluates active `/etc/wireguard/*.conf` files. Timestamped backup files are preserved for rollback and intentionally ignored when deciding whether the active configuration is safe.

## HashiCorp APT recovery

If the configured HashiCorp APT repository fails because the signing key is stale/missing, the installer:

- downloads only from `https://apt.releases.hashicorp.com/gpg`;
- parses the result as OpenPGP key material;
- verifies the reviewed fingerprint pinned in `core/install.sh`;
- refuses a mismatch;
- installs the keyring only after verification;
- keeps APT signature verification enabled;
- retries the update without `trusted=yes`, `--allow-unauthenticated`, or insecure-repository bypasses.

Key rotation is a source-review event, not an implicit runtime trust decision.

## Final acceptance

After recovery, reboot CORE and confirm SSH key login, routing, WireGuard handshake, `make core-check`, and `make core-find-conflict` still pass. A successful pre-reboot state alone is not persistent-recovery evidence.
