# zOS-Runner Operations

`zOS-Runner` is the repository self-hosted GitHub Actions runner used by zOS for Windows/x64 validation work.

## Current runner identity

- Scope: repository runner
- Display name: `zOS-Runner`
- Labels exposed by GitHub: `self-hosted`, `Windows`, `X64`
- Workflow target: `[self-hosted, Windows, X64]`

GitHub Actions routes jobs by labels, not by the runner display name. Do not put `zOS-Runner` in `runs-on` unless that exact custom label has been added to the runner.

## Security baseline

The runner should be treated as a privileged automation host.

- Use a dedicated Windows account with no interactive admin usage.
- Keep Windows Update, Git, PowerShell, and the GitHub runner current.
- Do not store RouterOS passwords, API tokens, private keys, or production secrets in the repository checkout.
- Prefer repository/environment secrets and short-lived credentials where possible.
- Do not run untrusted fork pull requests on the self-hosted runner.
- Keep the runner workspace on a dedicated disk/path and periodically remove stale work directories.
- Restrict inbound Windows Firewall access to only what is operationally required.
- Keep outbound HTTPS access to GitHub/GHCR available.
- Never use the runner workflow to apply live RouterOS configuration automatically.

## Validation workflow

`.github/workflows/routeros-skills.yml` is intentionally read-only. It performs:

1. Checkout with persisted Git credentials disabled.
2. Runner diagnostics.
3. Imported RouterOS skill structure validation.
4. Basic accidental-secret checks over `skills/`.
5. Job summary output.

Linux-specific repository validation remains in the Ubuntu-hosted workflows because the zOS shell tooling depends on Bash/ShellCheck and should not require extra Windows runner dependencies.

## Health checks

From PowerShell on the runner host:

```powershell
Get-Service | Where-Object Name -Like 'actions.runner*'
git --version
$PSVersionTable.PSVersion
Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsArchitecture
```

If the runner is installed interactively rather than as a Windows service, use the GitHub runner console output to verify it is `Listening for Jobs`.

## Updating the runner

GitHub runners normally self-update. If the runner becomes offline or incompatible:

1. Stop the runner service/process.
2. Back up only local runner configuration metadata if required.
3. Install the current GitHub Actions runner package.
4. Re-register only if GitHub reports the registration is invalid.
5. Verify the labels are still `self-hosted`, `Windows`, `X64`.
6. Dispatch `zOS RouterOS Skills Validation` manually.

## Troubleshooting

### Job remains queued

Check that the runner is online and has all labels in `runs-on`.

### PowerShell execution failure

The workflow uses `pwsh`. Install/repair PowerShell 7 if `pwsh` is unavailable.

### Checkout fails

Verify the runner can reach `github.com`, `api.github.com`, and GitHub object storage over HTTPS.

### Secret alert from imported skill

Review the exact file before changing the scanner. Do not broadly suppress the rule unless the content is confirmed to be documentation/example text rather than a credential.

## Production rule

The self-hosted runner is a CI validation surface, not the production network control channel. Live MikroTik operations remain operator-gated from the zOS controller path with backup, dry-run, Safe Mode, explicit change gates, and post-change verification.
