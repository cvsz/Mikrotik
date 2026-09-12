# Windows Runner VM

This directory documents the Windows VM used as the trusted self-hosted GitHub Actions runner for `cvsz/zos`.

## Identity

~~~text
VM hostname:     zeaz
Runner name:     zOS-Runner
Runner root:     D:\zOS-Runner
Scheduled task:  zOS-GitHub-Runner
Labels:          self-hosted, Windows, X64
Repository:      https://github.com/cvsz/zos
Shell:           pwsh
~~~

The runner is a CI execution surface only. It is not an implicit production RouterOS control plane.

## Environment template

Copy the template only when a local reference file is useful:

~~~powershell
Copy-Item runner\.env.example runner\.env
~~~

PowerShell and GitHub Actions Runner do not automatically load this file. Import values explicitly for a local diagnostic session if needed:

~~~powershell
Get-Content runner\.env |
  Where-Object { $_ -and -not $_.StartsWith('#') } |
  ForEach-Object {
    $name, $value = $_ -split '=', 2
    [Environment]::SetEnvironmentVariable($name, $value, 'Process')
  }
~~~

Do not persist runner registration tokens, PATs, credentials, private keys, or production secrets in this file.

## Trust rules

- one active `Runner.Listener` session;
- trusted repository workloads only;
- no untrusted fork execution;
- no ordinary live RouterOS apply;
- keep runner credentials under `D:\zOS-Runner` private;
- use Scheduled Task `zOS-GitHub-Runner` as the normal launcher.

See `../docs/SELF_HOSTED_RUNNER.md` for operations and recovery.
