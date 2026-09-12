# zOS / PoliceDBC Production Checklist

## Identity

- [ ] DEV is `core.zeaz.dev`.
- [ ] PROD is `prod.zeaz.dev`.
- [ ] SSH user is `zeazdev`.
- [ ] No new automation uses the historical DBC hostname.

## Before change

- [ ] Confirm local/recovery-capable management path.
- [ ] Confirm SSH and/or WinBox access.
- [ ] Run `00-PRECHECK.rsc` / `make audit`.
- [ ] Export current configuration.
- [ ] Create a backup.
- [ ] Run `make validate`.
- [ ] Dry-run every candidate RouterOS phase.
- [ ] Review the exact change plan.
- [ ] Enter RouterOS Safe Mode for risky production changes.
- [ ] Enable explicit live-apply gate only when ready.

## After change

- [ ] LAN gateway remains `192.168.1.1/24` on `bridge-lan`.
- [ ] WAN remains `192.168.205.251/21` on `ether1`.
- [ ] Default route remains via `192.168.200.1` unless intentionally changed.
- [ ] Internet connectivity passes.
- [ ] DNS resolution passes.
- [ ] SSH and WinBox remain reachable.
- [ ] WireGuard keys were preserved unless rotation was explicitly approved.
- [ ] DEV/CORE remains the known `10.8.0.2/32` peer.
- [ ] DEV physical LAN route uses `ens33`, not `policedbc`.
- [ ] Firewall/NAT behavior is verified.
- [ ] `99-VERIFY-HEALTH.rsc` / `make verify` passes.
- [ ] Post-change export/evidence is retained.

## CI/runner

- [ ] Hosted validation workflows pass.
- [ ] Self-hosted `zOS-Runner` is used only when explicitly intended.
- [ ] Scheduled Task `zOS-GitHub-Runner` is the sole background listener.
- [ ] No second manual `run.cmd` session is running.
