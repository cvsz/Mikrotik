# ZeaZDev MikroTik End-to-End Runbook

This is the primary operator sequence. Detailed recovery, SSH, GitHub, and release procedures are linked from `docs/INDEX.md`.

## 1. Prepare the controller

~~~bash
git clone https://github.com/cvsz/zos.git
cd zos
cp config/topology.env.example config/topology.env
chmod 600 config/topology.env
./tools/install-controller.sh
./zOS/bin/zos doctor
~~~

Review every topology value before use. Empty/unknown values must remain unknown until verified.

## 2. Establish CORE network and SSH

Update the repository as its owner, not root:

~~~bash
cd /home/<repo-owner>/zos
git pull --ff-only origin main
sudo ./core/install.sh
make core-check
make core-find-conflict
~~~

The secure installer path requires an existing public key and defaults to `PasswordAuthentication no`. Keep the current recovery session open until a separate client proves key-only login. See `docs/SSH-HARDENING.md`.

Required routing:

~~~text
default via 192.168.1.1 dev ens33
192.168.1.0/24 dev ens33
10.8.0.0/24 dev policedbc
~~~

Active `policedbc` configuration must not route `192.168.1.0/24`. Backups may retain the old value for rollback.

After a CORE recovery, reboot and repeat the route/WireGuard/SSH checks before claiming persistent success.

## 3. Validate repository state

~~~bash
make validate
make docs
make evidence
make security-evidence
./zOS/bin/zos help
~~~

Green repository checks are necessary but are not proof of live production readiness.

## 4. Inspect router state

~~~bash
make status
make audit
~~~

Stop when the observed router materially differs from the documented baseline. Resolve drift before applying planned changes.

## 5. Back up

~~~bash
make backup
~~~

Store text export evidence and binary backups in protected storage outside source control.

## 6. Dry-run intended phases

~~~bash
make dry-run
~~~

Active production phases:

~~~text
00-PRECHECK.rsc
10-BACKUP-SNAPSHOT.rsc
20-NETWORK-NORMALIZE.rsc
30-DHCP-DNS-NTP.rsc
40-WIREGUARD-SERVICES.rsc
50-FIREWALL-NAT.rsc
60-OBSERVABILITY.rsc
90-EXPORT-EVIDENCE.rsc
99-VERIFY-HEALTH.rsc
~~~

Historical `01-` through `07-` and old one-click paths are not the current production phase set.

## 7. Apply only in an approved change window

Use a recovery-capable session and Safe Mode or another verified rollback path for risky RouterOS work.

~~~bash
export OMEGA_ALLOW_LIVE_APPLY=1
make apply
~~~

Do not exit Safe Mode until independent verification succeeds.

## 8. Verify

~~~bash
make verify
make e2e
~~~

Independently verify management, WAN/default route, LAN/DHCP/DNS, WireGuard handshake, firewall/NAT, and intended service reachability.

## 9. Update automation

RouterOS update checks are safe/read-only by default:

~~~bash
make update-check
~~~

Unattended installation requires both `OMEGA_AUTO_ROUTEROS_UPDATE=1` and `OMEGA_ALLOW_ROUTER_REBOOT=1`. Do not enable them permanently without an approved operations design.

## 10. GitHub and runner

CI validates/builds/packages. It does not perform ordinary live production mutation. The optional `zOS-Runner` probe is trusted validation only. See `docs/GITHUB-OPERATIONS.md` and `docs/SELF_HOSTED_RUNNER.md`.

## 11. Acceptance

Use `CHECKLIST.md` and `docs/PRODUCTION-READINESS.md`. Record the commit/release, relevant CI runs, pre-change audit, backup identifiers, dry-run result, live-change approval if any, post-change verification, rollback outcome if exercised, and operator timestamp.
