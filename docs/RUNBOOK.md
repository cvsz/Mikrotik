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

## 5. Validate repository

```bash
make validate
./zOS/bin/zos help
```

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

## 11. Acceptance criteria

A change is complete only when:

- precheck/audit passes;
- backup/export exists;
- dry-run passes;
- management remains reachable;
- WAN/default route remains correct;
- LAN DHCP/DNS works;
- CORE routes physical LAN through `ens33`;
- WireGuard handshake is current;
- intended DEV/PROD reachability is verified;
- post-change export/evidence is retained.
