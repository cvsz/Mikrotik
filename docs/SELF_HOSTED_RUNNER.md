# zOS-Runner Operations

`zOS-Runner` is the repository self-hosted GitHub Actions runner used by zOS for Windows/x64 validation work.

## Current runner identity

- Scope: repository runner
- Display name: `zOS-Runner`
- Labels exposed by GitHub: `self-hosted`, `Windows`, `X64`
- Workflow target when explicitly probed: `[self-hosted, Windows, X64]`

GitHub Actions routes jobs by labels, not by the runner display name. Do not put `zOS-Runner` in `runs-on` unless that exact custom label has been added to the runner.

## Current incident: worker crashes before step 1

A repository run failed before any workflow step started with:

```text
System.ArgumentOutOfRangeException: Index and length must refer to a location within the string.
at GitHub.DistributedTask.Logging.ValueEncoders.PowerShellPreAmpersandEscape(String value)
at GitHub.DistributedTask.Logging.SecretMasker.AddValue(String value)
at GitHub.Runner.Worker.Worker.InitializeSecretMasker(...)
```

Because the failure occurs inside `Worker.InitializeSecretMasker` before checkout or user PowerShell executes, this is a self-hosted GitHub Actions runner process/runtime problem, not a RouterOS skill validation failure.

To keep pull requests unblocked, the normal `zOS RouterOS Skills Validation` job now runs on GitHub-hosted `windows-2025`. The self-hosted runner is isolated behind a manual `workflow_dispatch` input named `run_self_hosted` until the runner is repaired.

## Repair procedure

Run these commands in an elevated PowerShell on the Windows machine that hosts the runner. Adjust the runner directory if it is not `C:\actions-runner`.

```powershell
$RunnerRoot = 'C:\actions-runner'
Set-Location $RunnerRoot

# Record installed runner version and service state.
Get-Content .runner -ErrorAction SilentlyContinue
Get-Service | Where-Object Name -Like 'actions.runner*'
Get-Process Runner.Listener,Runner.Worker -ErrorAction SilentlyContinue
```

If installed as a service, restart it first:

```powershell
$svc = Get-Service | Where-Object Name -Like 'actions.runner*' | Select-Object -First 1
if ($svc) {
  Restart-Service $svc.Name -Force
  Start-Sleep -Seconds 5
  Get-Service $svc.Name
}
```

If the same exception returns, stop the runner and update/reinstall the current GitHub Actions runner release. Preserve `.runner`, `.credentials`, and `.credentials_rsaparams` only as registration metadata; never commit or share them.

Before replacing binaries:

```powershell
$svc = Get-Service | Where-Object Name -Like 'actions.runner*' | Select-Object -First 1
if ($svc) { Stop-Service $svc.Name -Force }
Get-Process Runner.Listener,Runner.Worker -ErrorAction SilentlyContinue | Stop-Process -Force
```

Then install the latest Windows x64 GitHub Actions runner package from the repository's **Settings → Actions → Runners → New self-hosted runner** instructions. Prefer the exact commands GitHub generates for the repository because registration tokens are short-lived.

After reinstall/update, verify:

```powershell
Get-Service | Where-Object Name -Like 'actions.runner*'
Get-Process Runner.Listener -ErrorAction SilentlyContinue
```

The runner should report `Idle` / `Listening for Jobs` in GitHub before testing it.

## Minimal post-repair test

Use **Actions → zOS RouterOS Skills Validation → Run workflow** and enable `run_self_hosted=true`.

The self-hosted probe intentionally contains only:

```powershell
Write-Host "Runner: $env:RUNNER_NAME"
Write-Host "OS: $env:RUNNER_OS"
Write-Host "Arch: $env:RUNNER_ARCH"
$PSVersionTable.PSVersion.ToString()
```

If this still fails before the first step, do not edit RouterOS code or skill files. Continue troubleshooting the runner installation/service/runtime.

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

## Health checks

From PowerShell on the runner host:

```powershell
Get-Service | Where-Object Name -Like 'actions.runner*'
git --version
pwsh --version
Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsArchitecture
```

If the runner is installed interactively rather than as a Windows service, use the GitHub runner console output to verify it is `Listening for Jobs`.

## Troubleshooting

### Job remains queued

Check that the runner is online and has all labels in `runs-on`.

### Worker fails before checkout

Treat `Worker.InitializeSecretMasker`, `PowerShellPreAmpersandEscape`, or similar stack traces as a runner-runtime incident. Restart/update/reinstall the runner before changing workflow scripts.

### PowerShell execution failure after a step starts

The workflow uses `pwsh`. Install/repair PowerShell 7 if `pwsh` is unavailable.

### Checkout fails

Verify the runner can reach `github.com`, `api.github.com`, and GitHub object storage over HTTPS.

### Secret alert from imported skill

Review the exact file before changing the scanner. Do not broadly suppress the rule unless the content is confirmed to be documentation/example text rather than a credential.

## Production rule

The self-hosted runner is a CI validation surface, not the production network control channel. Live MikroTik operations remain operator-gated from the zOS controller path with backup, dry-run, Safe Mode, explicit change gates, and post-change verification.
