# RouterOS Production Runbook

## 5. Backup and evidence

Before any production change, run the repository backup/evidence workflow and keep its outputs in protected storage outside source control.

`make backup` now creates both a text export and an AES-SHA256 encrypted RouterOS binary backup. The binary and its generated password are downloaded to `backups/` with restrictive permissions, and the temporary RouterOS files are removed after successful download.

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

The dry-run uploads a unique temporary file only because RouterOS `import ... dry-run` consumes a file. The file is removed by the controller after the import attempt. No configuration import is treated as successful unless the dry-run command itself succeeds.

The controller records a local dry-run manifest containing SHA-256 hashes of every active phase. Live apply refuses to proceed when that manifest is missing or stale.

Historical `01-` through `07-` and old one-click paths are not the current production phase set.

## 7. Apply only in an approved change window

The topology contract enables both mandatory gates by default:

~~~text
OMEGA_REQUIRE_DRY_RUN=1
OMEGA_REQUIRE_SAFE_MODE=1
OMEGA_ALLOW_LIVE_APPLY=0
~~~

After `make dry-run` has completed successfully, set the live-apply flag only for the approved change window:

~~~bash
export OMEGA_ALLOW_LIVE_APPLY=1
make apply
~~~

When `OMEGA_REQUIRE_SAFE_MODE=1`, zOS opens one interactive RouterOS CLI session, sends the Safe Mode toggle (Ctrl-X), requires RouterOS to return `[Safe Mode taken]`, imports all phases in that same session, and exits with `/quit`. If Safe Mode is not confirmed, the apply is failed rather than reported as successful. Do not use the legacy `apply` path to bypass this controller.

Do not exit Safe Mode until independent verification succeeds.

## 8. Verify

~~~bash
make verify
make e2e
~~~

Independently verify management, WAN/default route, LAN/DHCP/DNS, WireGuard handshake, firewall/NAT, and intended service reachability.

## 9. Update automation

RouterOS update checks are read-only with respect to the persistent update channel:

~~~bash
make update-check
~~~

The checker reads the router's current channel and refuses to change it when `ROUTEROS_UPDATE_CHANNEL` differs. This avoids the previous `set channel=...` mutation during a check.

Unattended installation requires both `OMEGA_AUTO_ROUTEROS_UPDATE=1` and `OMEGA_ALLOW_ROUTER_REBOOT=1`. The install command's exit status is not blindly swallowed: a non-zero status other than the expected SSH disconnect during reboot fails the operation, and after reboot the running RouterOS version must differ from the pre-update version. A reachable router with the same version is a failed update, not success.

## 10. GitHub and runner

CI validates/builds/packages. It does not perform ordinary live production mutation. The optional `zOS-Runner` probe is trusted validation only. See `docs/GITHUB-OPERATIONS.md` and `docs/SELF_HOSTED_RUNNER.md`.

## 11. Acceptance

Use `CHECKLIST.md` and `docs/PRODUCTION-READINESS.md`. Record the commit/release, relevant CI runs, pre-change audit, backup identifiers, dry-run manifest, live-change approval if any, post-change verification, rollback outcome if exercised, and operator timestamp.
