# ZeaZDev MikroTik End-to-End Runbook

## 1. Prepare DEV/CORE controller

On `core.zeaz.dev` as `zeazdev`:

```bash
git clone https://github.com/cvsz/zos.git
cd zos
cp config/topology.env.example config/topology.env
chmod 600 config/topology.env
chmod +x tools/*.sh zOS/bin/zos zOS/install.sh
./tools/install-controller.sh
./zOS/bin/zos doctor
```

Import the generated controller public key into the intended MikroTik management user through a verified management session. Never commit private keys or passwords.

## 2. Verify/repair CORE networking first

If CORE needs SSH bootstrap/recovery, update the repository as its normal owner and then run the privileged installer:

```bash
cd /home/cvsz/zos
git pull --ff-only origin main
sudo ./core/install.sh
```

Do not run `git pull` from a root shell in a user-owned working tree. If already root, execute Git as the repository owner instead of weakening Git's `safe.directory` protection.

### SSH production baseline

`core/install.sh` now defaults to:

```text
SSH_ALLOW_PASSWORD=no
```

It refuses to write a password-disabled SSH configuration unless the selected `SSH_USER` already has a non-empty `~/.ssh/authorized_keys` file. If emergency bootstrap access is genuinely required before a key can be installed, make that exception explicit for that run only:

```bash
sudo SSH_ALLOW_PASSWORD=yes ./core/install.sh
```

After key login is proven, rerun with the default fail-closed setting.

### HashiCorp APT key recovery

If APT encounters a stale/missing HashiCorp repository key, the installer fetches only the official `apt.releases.hashicorp.com/gpg` key and verifies the pinned package-signing fingerprint before installing it:

```text
D55C 0D1A C78A 8D81 26CB 631C FC9C A96A CA02 6560
```

A mismatch is fatal. The installer never uses `trusted=yes`, `--allow-unauthenticated`, or another APT signature bypass.

The installer remains deliberately conservative: it removes only the conflicting runtime `192.168.1.0/24` route from `policedbc`, refuses to continue if the gateway is not selected through `ens33`, installs/enables OpenSSH, validates `sshd`, and changes UFW only when UFW is already active. Persistent WireGuard/network-manager configuration remains operator-controlled.

Then verify:

```bash
make core-status
make core-check
```

Expected routing:

```text
default via 192.168.1.1 dev ens33
192.168.1.0/24 dev ens33
10.8.0.0/24 dev policedbc
```

If `ens33` has carrier but the physical LAN is incorrectly routed through `policedbc`:

```bash
make core-repair
make core-find-conflict
```

The persistent WireGuard configuration must not install `192.168.1.0/24` through `policedbc`.

## 3. Verify router state

```bash
make status
make audit
```

Stop if the real router baseline differs materially from `config/topology.env`.

## 4. Back up

```bash
make backup
```

Keep text export evidence and the RouterOS backup in protected storage before high-risk changes.

## 5. Validate repository and evidence

```bash
make validate
make evidence
make security-evidence
./zOS/bin/zos help
```

Repository/CI success is necessary but not proof of live production readiness; retain generated evidence and separately verify runtime state.

## 6. Dry-run the active phase set

```bash
make dry-run
```

Active phases:

```text
00-PRECHECK.rsc
10-BACKUP-SNAPSHOT.rsc
20-NETWORK-NORMALIZE.rsc
30-DHCP-DNS-NTP.rsc
40-WIREGUARD-SERVICES.rsc
50-FIREWALL-NAT.rsc
60-OBSERVABILITY.rsc
90-EXPORT-EVIDENCE.rsc
99-VERIFY-HEALTH.rsc
```

Do not execute deprecated historical phase files as the production stack.

## 7. Production apply

Use a local or recovery-capable management session and RouterOS Safe Mode for risky changes. Only after backup and dry-run are clean:

```bash
export OMEGA_ALLOW_LIVE_APPLY=1
make apply
```

Do not exit Safe Mode until independent verification succeeds.

## 8. Verify

```bash
make verify
make e2e
```

Independently verify management, WAN/default route, DNS, WireGuard handshake, firewall/NAT, and target behavior.

## 9. PROD host

Canonical production endpoint is `prod.zeaz.dev`, user `zeazdev`. `PROD_LAN_IP` and `PROD_WG_IP` remain unset until observed. Do not invent them.

## 10. Self-hosted runner

The Windows runner is `zOS-Runner` at `D:\zOS-Runner`, launched by Scheduled Task `zOS-GitHub-Runner`.

Normal RouterOS skills validation runs on GitHub-hosted Windows. Use the self-hosted runner only through the explicit manual probe until end-to-end job execution is proven healthy.

Do not start a second manual `run.cmd` while the Scheduled Task listener is active.

## 11. Production acceptance criteria

A deployment is production-ready only when all applicable items are evidenced:

- repository validation and evidence workflows pass;
- CORE has stable carrier, IPv4 and default route through `ens33`;
- SSH key login is proven and password authentication is disabled unless an explicit temporary exception is documented;
- HashiCorp APT package key matches the pinned reviewed fingerprint if repair was required;
- router precheck/audit passes;
- backup/export exists and is stored safely;
- every intended RouterOS phase dry-runs cleanly;
- management remains reachable during/after change;
- WAN/default route remains correct;
- LAN DHCP/DNS works;
- WireGuard handshake is current;
- firewall/NAT behavior is verified;
- intended DEV/PROD reachability is verified;
- `make verify` and `make e2e` pass;
- post-change export/evidence is retained.
