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

For key recovery, use the tracked helper with an explicit target and local private key validation:

~~~bash
./core/install-ssh-key.sh --host <core-ip-or-hostname> --user <core-user> --private-key <private-key-path>
~~~

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

`make backup` creates a text export and an AES-SHA256 encrypted binary RouterOS backup, downloads both, stores the generated backup password with mode 600, and removes the temporary backup files from the router after successful download. Store the local evidence in protected storage outside source control.

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

The dry-run uses a unique temporary RouterOS file because `import ... dry-run` consumes a file. The controller removes that file after the import attempt. No configuration import is treated as successful unless the dry-run command succeeds.

A successful dry-run records a local SHA-256 manifest of the exact active phase files. `make apply` refuses to continue if the manifest is absent or stale.

Historical `01-` through `07-` and old one-click paths are not the current production phase set.

## 7. Apply only in an approved change window

The topology contract is fail-closed by default:

~~~text
OMEGA_REQUIRE_DRY_RUN=1
OMEGA_REQUIRE_SAFE_MODE=1
OMEGA_ALLOW_LIVE_APPLY=0
~~~

After a successful dry-run, set the live-apply flag only for the approved change window:

~~~bash
export OMEGA_ALLOW_LIVE_APPLY=1
make apply
~~~

When `OMEGA_REQUIRE_SAFE_MODE=1`, zOS opens one interactive RouterOS CLI session, sends the Safe Mode toggle (Ctrl-X), requires RouterOS to report `[Safe Mode taken]`, imports all phases in that same session, and requires an explicit all-phases success sentinel before treating the operation as successful. If Safe Mode is not confirmed, apply fails closed. Do not bypass this controller with individual `omega-router.sh apply` calls.

Do not exit Safe Mode until independent verification succeeds.

## 8. Verify

~~~bash
make verify
make e2e
~~~

Independently verify management, WAN/default route, LAN/DHCP/DNS, WireGuard handshake, firewall/NAT, and intended service reachability.

## 9. Update automation

RouterOS update checks are read-only with respect to persistent configuration:

~~~bash
make update-check
~~~

The checker reads the router's current update channel and refuses to change it when `ROUTEROS_UPDATE_CHANNEL` differs. It does not execute `/system package update set channel=...` during a check.

Unattended installation requires both `OMEGA_AUTO_ROUTEROS_UPDATE=1` and `OMEGA_ALLOW_ROUTER_REBOOT=1`. The install command's failure status is not blindly swallowed: non-zero statuses other than the expected SSH disconnect during reboot fail the operation, and after reboot the running RouterOS version must differ from the pre-update version. A reachable router with the same version is reported as update failure.

## 10. GitHub and runner

CI validates/builds/packages. It does not perform ordinary live production mutation. The optional `zOS-Runner` probe is trusted validation only. See `docs/GITHUB-OPERATIONS.md` and `docs/SELF_HOSTED_RUNNER.md`.

## 11. Acceptance

Use `CHECKLIST.md` and `docs/PRODUCTION-READINESS.md`. Record the commit/release, relevant CI runs, pre-change audit, backup identifiers, dry-run manifest, live-change approval if any, post-change verification, rollback outcome if exercised, and operator timestamp.
