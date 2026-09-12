# Security Policy

## Scope

This repository controls production-sensitive MikroTik RouterOS infrastructure. Treat RouterOS scripts, topology, credentials, SSH keys, WireGuard keys, backups and exports as sensitive operational material.

## Rules

- Never commit private keys, passwords, tokens, RouterOS binary backups, production exports containing secrets, or `.env` files.
- Use `config/topology.env` locally; commit only `config/topology.env.example`.
- Production changes require backup, dry-run, RouterOS Safe Mode and post-change verification.
- Automatic RouterOS upgrades are disabled by default and require explicit update + reboot gates.
- zOS must run on the controller (`core.zeaz.dev`), not replace RouterOS firmware.

## Reporting

For a suspected vulnerability, avoid opening a public issue with secrets, credentials, topology dumps or exploitable details. Use GitHub private vulnerability reporting when available or contact the repository owner privately.
