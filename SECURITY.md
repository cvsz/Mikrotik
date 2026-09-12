# Security Policy

## Scope

This repository controls production-sensitive MikroTik RouterOS infrastructure and zOS controller behavior. Treat scripts, topology, credentials, SSH keys, WireGuard keys, backups, exports, and GitHub runner credentials as sensitive operational material.

## Mandatory rules

- Never commit private keys, passwords, tokens, runner credentials, RouterOS binary backups, production exports containing secrets, or local secret-bearing `.env` files.
- Use `config/topology.env` locally; commit only `config/topology.env.example`.
- Production RouterOS mutations require audit, backup, dry-run, a recovery path, explicit operator opt-in, and post-change verification.
- Use RouterOS Safe Mode for risky live changes where appropriate.
- Automatic RouterOS upgrades remain disabled by default and require explicit update and reboot gates.
- zOS runs on `core.zeaz.dev`; it does not replace RouterOS firmware.
- Never weaken validation or secret scanning solely to make CI pass.
- Do not run untrusted fork pull requests on the privileged self-hosted runner.
- Do not treat an HTTP 200 from RouterOS `/rest/execute` as proof that a command succeeded.

## Self-hosted runner

The repository runner is `zOS-Runner` under `D:\zOS-Runner`, launched by Scheduled Task `zOS-GitHub-Runner`.

Security expectations:

- keep Windows, Git, PowerShell, and the runner current;
- restrict the runner to trusted repository workloads;
- do not store long-lived production credentials in the checkout;
- keep runner registration/credential files out of source control;
- periodically clean stale workspaces;
- keep normal production mutation out of CI.

## Reporting

For a suspected vulnerability, do not open a public issue containing secrets, credentials, topology dumps, or exploitable details. Use GitHub private vulnerability reporting when available or contact the repository owner privately.
