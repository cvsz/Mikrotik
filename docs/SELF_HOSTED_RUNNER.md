# zOS-Runner Operations

`zOS-Runner` is a repository-scoped Windows x64 self-hosted GitHub Actions runner for trusted validation probes.

## Identity

- VM hostname: `zeaz`;
- repository: `cvsz/zos`;
- display name: `zOS-Runner`;
- root path: `D:\zOS-Runner`;
- labels: `self-hosted`, `Windows`, `X64`;
- launcher: Scheduled Task `zOS-GitHub-Runner`.

GitHub schedules by labels. Do not assume the display name is a label.

## Environment template

The runner VM has a secret-free reference template at `runner/.env.example`. It records the hostname, runner identity, root path, scheduled task, labels, shell, and fail-closed trust posture.

The runner does not auto-load this file. Do not store registration tokens, GitHub PATs, runner credentials, private keys, or production secrets in it. See `runner/README.md` for an explicit PowerShell import example.

## Single-listener rule

The Scheduled Task owns the normal listener. Do not manually start a second `run.cmd` while it is active. A duplicate-session error usually indicates the first listener is already connected, not that re-registration is required.

## Health check

~~~powershell
$task = Get-ScheduledTask -TaskName 'zOS-GitHub-Runner'
$listener = Get-Process Runner.Listener -ErrorAction SilentlyContinue
[pscustomobject]@{
  TaskState = $task.State
  Listener  = if ($listener) { 'RUNNING' } else { 'STOPPED' }
  PID       = $listener.Id
}
~~~

Expected idle state: listener running, no worker. `Runner.Worker` appears while a job executes.

## Manual validation probe

`routeros-skills.yml` exposes an explicit `workflow_dispatch` option to run the self-hosted probe. It remains validation-only and must not apply RouterOS configuration.

## Diagnostics

Inspect newest files under `D:\zOS-Runner\_diag` when the worker fails before workflow step 1. Sanitize logs before sharing; they may contain environment or registration-sensitive material.

## Restart

~~~powershell
Stop-ScheduledTask -TaskName 'zOS-GitHub-Runner'
Get-Process Runner.Listener,Runner.Worker -ErrorAction SilentlyContinue | Stop-Process -Force
Start-ScheduledTask -TaskName 'zOS-GitHub-Runner'
~~~

Re-register only when the runner identity/credentials are actually invalid.

## Security

- trusted repository workloads only;
- no untrusted fork execution;
- no production secrets in checkout;
- keep `.runner`, `.credentials`, and `.credentials_rsaparams` private;
- keep Windows/Git/PowerShell/runner package current;
- restrict inbound access and allow only required outbound GitHub/GHCR connectivity;
- do not use the runner as an implicit live production control channel.

## Governance

Changes to runner trust, labels, registration model, or production permissions require documentation updates in `SECURITY.md`, `docs/GITHUB-OPERATIONS.md`, and this file.
