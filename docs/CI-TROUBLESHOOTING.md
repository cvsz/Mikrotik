# CI and Operator Failure-Mode Troubleshooting

This runbook maps recurring failure signatures to safe diagnosis. Keep evidence sanitized.

## `Permission denied` / exit 126 for `./tools/*.sh`

Meaning: the script is not executable in the checkout or the filesystem/mount disallows execution.

Actions:

1. run `git ls-files -s <path>` and confirm mode `100755` for operational entry points;
2. run `ls -l <path>`;
3. verify the checkout/mount is not `noexec`;
4. fix the Git mode in the repository rather than teaching normal workflows to rely on ad-hoc `chmod`.

## Git `detected dubious ownership`

Meaning: Git is correctly refusing a repository owned by another account.

Actions:

- leave the root shell and run Git as the repository owner; or
- execute Git explicitly as that owner.

Do not add a broad global `safe.directory` exception merely to make root operate in a user-owned checkout.

## SSH `Permission denied (publickey)`

Meaning: TCP/22 and sshd may be reachable, but the target account did not accept an offered key.

Check `authorized_keys`, ownership/mode, the client identity selected, `sshd -T`, and server logs. Keep the recovery session open until key-only login is proven.

## APT `NO_PUBKEY FC9CA96ACA026560` for HashiCorp

`core/install.sh` has a fail-closed repair path using the reviewed HashiCorp endpoint and pinned fingerprint. Do not disable APT signature verification or mark the repository trusted.

## WireGuard conflict output shows only `.bak.*`

Historical backup files may contain the old physical-LAN `AllowedIPs` line. `make core-find-conflict` evaluates active `/etc/wireguard/*.conf` files and intentionally ignores backups for active-state PASS/FAIL.

## Broken project Markdown reference

Run:

~~~bash
make docs
~~~

Fix the relative link or add the intended document. Do not weaken the documentation validator to preserve a stale reference.

## Broken vendored skill Markdown reference

Use the RouterOS skills workflow and preserve upstream/provenance semantics. Project documentation validation and vendored skill validation are separate by design.

## Runner session conflict

`A session for this runner already exists` usually means a second listener was started. Inspect Scheduled Task `zOS-GitHub-Runner`; do not re-register the runner just because another `run.cmd` instance conflicts.

## Runner worker initialization failure

If failure occurs before workflow step 1, inspect the newest runner diagnostics under `D:\zOS-Runner\_diag`. Treat that as runner-runtime evidence, not a RouterOS test failure.

## Secret scanner finding

Remove and rotate a real secret immediately. For a false positive, narrow only the specific rule/case; do not globally weaken secret protection.

## `ImagePullBackOff`

Verify the authoritative image name/tag, registry access, credentials, architecture, and existence of the replacement tag before changing manifests.

## Evidence hygiene

Do not commit raw runner logs, credentials, private URLs, private keys, tokens, binary backups, or sensitive production exports. Commit only sanitized signatures and durable diagnoses.
