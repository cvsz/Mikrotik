# ZeaZDev MikroTik End-to-End Runbook

## 1. Prepare DEV/CORE controller

On `core.zeaz.dev` as `zeazdev`:

```bash
git clone https://github.com/cvsz/Mikrotik.git
cd Mikrotik
cp config/topology.env.example config/topology.env
chmod 600 config/topology.env
chmod +x tools/*.sh
./tools/install-controller.sh
```

Import the generated `~/.ssh/omega_mikrotik.pub` into the intended MikroTik management user through a verified management session. Do not copy private keys or passwords into this repository.

## 2. Repair/verify CORE networking first

```bash
make core-status
make core-check
```

If `ens33` has carrier but the physical LAN is routed through `policedbc`:

```bash
make core-repair
make core-find-conflict
```

The persistent WireGuard configuration must not install `192.168.1.0/24` through `policedbc` because that is the physical LAN.

Expected DEV routing:

```text
default via 192.168.1.1 dev ens33
192.168.1.0/24 dev ens33
10.8.0.0/24 dev policedbc
```

## 3. Verify router access

```bash
make status
make audit
```

Stop if the real router baseline differs materially from `config/topology.env`.

## 4. Back up

```bash
make backup
```

Keep both the text export downloaded under `backups/` and the RouterOS binary `.backup` retained on the router. Copy backups to a protected external location before high-risk changes.

## 5. Validate repository

```bash
make validate
```

CI performs the same static topology, destructive-pattern, shell and secret checks.

## 6. Dry-run the complete phase set

```bash
make dry-run
```

This uploads and runs RouterOS `verbose=yes dry-run` imports. It does not intentionally apply live configuration.

## 7. Production apply

Use a local/recovery-capable management session and enable RouterOS Safe Mode first. Only after all dry-runs are clean:

```bash
export OMEGA_ALLOW_LIVE_APPLY=1
make apply
```

Do not exit Safe Mode until verification succeeds.

## 8. Verify

```bash
make verify
```

Verify independently from DEV/CORE:

```bash
ping -c 3 192.168.1.1
ping -c 3 1.1.1.1
getent hosts cloudflare.com
ssh prod.zeaz.dev
```

Also verify WinBox/SSH management and a fresh WireGuard handshake.

## 9. PROD host

Canonical production endpoint is `prod.zeaz.dev`, user `zeazdev`. `PROD_LAN_IP` and `PROD_WG_IP` are intentionally unset until observed from the real host/router. Do not invent these addresses in automation.

## 10. Change acceptance criteria

A network change is complete only when:

- router precheck passes;
- backup/export exists;
- dry-run passes;
- management remains reachable;
- WAN/default route unchanged unless explicitly planned;
- LAN DHCP/DNS work;
- DEV/CORE routes physical LAN via `ens33`;
- WireGuard handshake is current;
- `core.zeaz.dev` and `prod.zeaz.dev` resolve/reach according to the intended exposure model;
- post-change export/evidence is retained.
