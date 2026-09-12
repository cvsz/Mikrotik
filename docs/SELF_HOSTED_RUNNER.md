# zOS-Runner Operations

`zOS-Runner` is the repository self-hosted GitHub Actions runner used for explicit Windows/x64 validation probes.

## Current identity

- Scope: repository runner
- Display name: `zOS-Runner`
- Install/root path: `D:\zOS-Runner`
- Labels: `self-hosted`, `Windows`, `X64`
- Scheduled Task: `zOS-GitHub-Runner`
- Repository: `cvsz/zos`

GitHub Actions dispatches by labels, not display name. Use:

```yaml
runs-on: [self-hosted, Windows, X64]
```

Do not put `zOS-Runner` in `runs-on` unless that custom label is explicitly added.

## Current launch model

This installation is launched by Windows Scheduled Task `zOS-GitHub-Runner`, not a Windows service helper.

Verify:

```powershell
Get-ScheduledTask -TaskName 'zOS-GitHub-Runner'
(Get-ScheduledTask -TaskName 'zOS-GitHub-Runner').Actions
Get-Process -ErrorAction SilentlyContinue |
    Where-Object ProcessName -in @('Runner.Listener','Runner.Worker')
```

Expected task action:

```text
cmd.exe /c "D:\zOS-Runner\run.cmd"
```

Expected idle state is a running `Runner.Listener` and no `Runner.Worker`. A worker appears while a job executes.

## Avoid duplicate sessions

When the Scheduled Task listener is running, do not launch `D:\zOS-Runner\run.cmd` manually.

A second listener using the same runner identity produces a session conflict indicating another listener already owns the GitHub session. That is not a reason to re-register the runner.

## Historical worker-runtime incident

Earlier self-hosted jobs failed before step 1 with a runner worker initialization exception involving `PowerShellPreAmpersandEscape` and `Worker.InitializeSecretMasker`.

Because the failure happened before user workflow steps, it was treated as a runner-runtime incident rather than a RouterOS skill failure.

Normal RouterOS skills validation therefore runs on GitHub-hosted `windows-2025`. The self-hosted runner remains behind manual `workflow_dispatch` input `run_self_hosted=true` until successful end-to-end job execution proves the runtime healthy.

## Health check

```powershell
$task = Get-ScheduledTask -TaskName 'zOS-GitHub-Runner'
$listener = Get-Process Runner.Listener -ErrorAction SilentlyContinue

[pscustomobject]@{
  TaskState      = $task.State
  RunnerListener = if ($listener) { 'RUNNING' } else { 'STOPPED' }
  RunnerPID      = $listener.Id
  RunnerPath     = 'D:\zOS-Runner'
}
```

Inspect diagnostics:

```powershell
Get-ChildItem D:\zOS-Runner\_diag |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 10 Name,LastWriteTime
```

## Manual probe

Use **Actions → zOS RouterOS Skills Validation → Run workflow** and set `run_self_hosted=true`.

The probe must remain validation-only and must not apply RouterOS configuration.

If a job fails before step 1, inspect the newest `Worker_*.log` and `Runner_*.log` under `D:\zOS-Runner\_diag` before changing workflow code.

## Restart procedure

```powershell
Stop-ScheduledTask -TaskName 'zOS-GitHub-Runner'
Get-Process Runner.Listener,Runner.Worker -ErrorAction SilentlyContinue | Stop-Process -Force
Start-ScheduledTask -TaskName 'zOS-GitHub-Runner'
Start-Sleep 3
Get-ScheduledTask -TaskName 'zOS-GitHub-Runner'
```

Do not re-register unless the runner identity or credentials are actually invalid.

## Security baseline

- Treat the runner host as privileged automation infrastructure.
- Do not run untrusted fork code.
- Keep registration tokens and credential files private.
- Do not commit `.runner`, `.credentials`, or `.credentials_rsaparams`.
- Keep Windows, Git, PowerShell, and the runner package current.
- Keep normal production RouterOS mutation outside CI.
- Restrict inbound access and allow required outbound HTTPS to GitHub/GHCR.

## Production rule

The self-hosted runner is a CI/validation surface, not the production network control channel. Live MikroTik work remains operator-gated through zOS with backup, dry-run, recovery access/Safe Mode where appropriate, explicit opt-in, and verification.
