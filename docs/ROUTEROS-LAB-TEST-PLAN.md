# Minimal RouterOS Lab Test Plan

This plan validates the zOS RouterOS safety controls on a **disposable, isolated RouterOS lab device only**. It is not a production procedure.

## Safety boundary

- Never point `ROUTEROS_HOST`, `ROUTEROS_SSH_HOST`, or any equivalent target at PROD/CORE.
- Use a spare RouterBOARD/CHR/VM with no production routes, DNS, DHCP clients, WireGuard peers, or credentials.
- Use a dedicated management address and a disposable admin key.
- Keep a second management session available for Safe Mode rollback testing.
- Default controller posture remains fail-closed:

~~~text
OMEGA_ALLOW_LIVE_APPLY=0
OMEGA_REQUIRE_DRY_RUN=1
OMEGA_REQUIRE_SAFE_MODE=1
~~~

RouterOS `import ... verbose=yes dry-run` is intended to simulate imports without configuration changes. RouterOS Safe Mode is session-local and is toggled with Ctrl-X/F4; changes are rolled back when the Safe Mode session is abnormally terminated. See the official RouterOS documentation before the first lab run.

## Lab fixture

Create harmless, non-production state that makes ownership behavior observable:

1. An unrelated DHCP server and DHCP network with a comment that does **not** identify zOS ownership.
2. An unrelated firewall filter rule and NAT rule in the same areas zOS manages.
3. An unrelated DNS static entry using a different name/address.
4. No existing zOS-owned rules, addresses, DHCP objects, or DNS entries at first.
5. Record a pre-test export and `/system package print` output outside the router.

Do not use the production IPs, hostnames, WireGuard keys, or credentials as lab fixtures.

## Test matrix

| ID | Test | Expected result | Evidence |
|---|---|---|---|
| SM-01 | Safe Mode apply on lab router | Controller reports `[Safe Mode taken]` and `OMEGA_APPLY_PASS`; intended lab changes persist after clean `/quit` | controller log + router export |
| SM-02 | Safe Mode rollback | Start an apply, then terminate the SSH/CLI session abnormally before `/quit`; zOS changes disappear | before/after export |
| DR-01 | Required dry-run | `make dry-run` succeeds and records the exact active-phase manifest | command output + manifest |
| DR-02 | Stale/missing manifest gate | Change one active `.rsc` after dry-run, then `make apply`; apply is refused before live mutation | controller output |
| DR-03 | Live-apply gate | With `OMEGA_ALLOW_LIVE_APPLY=0`, `make apply` refuses to connect/apply | controller output |
| UP-01 | Read-only update check | `make update-check` does not persistently change `/system package update channel` | before/after channel output |
| UP-02 | Update verification | On a disposable lab image with an available RouterOS update, install is not reported successful unless the running version changes after reboot | before/after version output |
| BK-01 | Encrypted backup | `make backup` downloads an AES-SHA256 binary backup and text export; backup password is stored locally with mode 600 | local files + router file listing |
| BK-02 | Backup cleanup | After successful download, temporary `.backup` and `.rsc` files created by the controller are absent from the router | router file listing |
| OWN-01 | Preserve unowned DHCP | Apply phase 30 against the fixture; unrelated DHCP server/network remains unchanged | before/after export |
| OWN-02 | Preserve unowned firewall/NAT | Apply phase 50; unrelated rules remain unchanged | before/after export |
| OWN-03 | Reject ownership conflict | Present an existing unowned object where zOS expects ownership; apply fails closed rather than deleting/replacing it | controller output + export |
| OWN-04 | No invented CORE mapping | Apply phase 30 with no runtime CORE evidence; no `core.zeaz.internal -> 192.168.1.128` entry appears | DNS export |

## Execution order

Run in this order and stop on the first unexpected mutation:

### 1. Repository gates

~~~bash
make validate
make docs
~~~

Record the commit SHA. Do not continue if repository validation fails.

### 2. Baseline lab snapshot

~~~bash
make status
make audit
make backup
~~~

Confirm the backup is encrypted and that temporary router files are cleaned up.

### 3. Dry-run gate

~~~bash
make dry-run
~~~

Confirm the command succeeds and produces the local active-phase SHA-256 manifest. Confirm no intended configuration object changed.

Then deliberately modify one active phase file and repeat:

~~~bash
make apply
~~~

Expected: refusal because the manifest is stale. Restore the file before continuing.

### 4. Safe Mode happy path

Set only the lab target and temporary live-apply permission:

~~~bash
export OMEGA_ALLOW_LIVE_APPLY=1
make apply
~~~

Expected:

- Safe Mode is explicitly taken.
- Every active phase is imported in the same Safe Mode session.
- `OMEGA_APPLY_PASS` is emitted only after all phases succeed.
- The command exits successfully.
- Keep Safe Mode active until independent verification completes.

### 5. Safe Mode rollback

Repeat the apply against the lab router, but deliberately terminate the interactive SSH session before the final `/quit`/success sentinel. Reconnect and export the configuration.

Expected: zOS changes made inside Safe Mode are rolled back. If they persist, stop testing and treat the Safe Mode controller path as failed.

### 6. Ownership tests

Restore the fixture and test each ownership boundary independently.

Expected behavior:

- zOS-owned objects may be created/updated by the phase.
- Existing unowned DHCP, DNS, firewall, and NAT objects are preserved.
- An ownership conflict causes a hard failure instead of takeover.
- No unrelated named-chain rule is deleted merely because it shares a chain with zOS rules.

### 7. Update verification

First run the read-only check and record the current channel and running version.

~~~bash
make update-check
~~~

Confirm the channel is unchanged. For `update-auto`, use only a disposable lab image and explicitly enable the documented reboot/update flags. Record the version before and after reboot.

Expected: a reachable router with the same running version is reported as update failure when an update was expected. Installation errors must not be swallowed.

### 8. Cleanup

Remove the lab-only zOS state and restore the fixture from its baseline export. Confirm the router contains no controller-created temporary files and no production credentials or addresses.

## Exit criteria

The lab is a pass only when all of the following are true:

- Safe Mode happy path succeeds and rollback is demonstrated.
- Dry-run is mandatory and stale manifests are rejected.
- Live apply is impossible with `OMEGA_ALLOW_LIVE_APPLY=0`.
- Update check is configuration-read-only.
- Expected update installs are verified by a changed running version.
- Backups are encrypted and controller-created router files are cleaned up.
- Unowned DHCP/DNS/firewall/NAT state is preserved.
- Ownership conflicts fail closed.
- No hard-coded CORE LAN mapping is introduced.

A lab pass is **not** production approval. Production still requires an independent audit, approved change window, operator review, and post-change verification.
