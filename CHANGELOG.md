# Changelog

Notable repository and operational changes are recorded here. zOS has not yet declared a stable public API; version numbers below describe repository milestones.

## Unreleased

### Documentation and GitHub operations
- Rebuilt the project documentation map and added architecture, installation, testing, release, network-recovery, SSH-hardening, GitHub-operations, roadmap, support, governance, maintainer, and licensing guidance.
- Added GitHub community templates and CODEOWNERS guidance.
- Added documentation validation to prevent stale repository names and broken local Markdown references.
- Clarified the difference between desired automation identity and the actual operator/recovery account on an existing CORE host.
- Removed transient DEV DHCP addressing from the canonical example contract.
- Added root, CORE, and zOS `.env.example` templates with fail-closed defaults and documented loading/secret-handling rules.

### CORE recovery/hardening
- Added fail-closed OpenSSH bootstrap/recovery for CORE.
- Defaulted SSH password authentication to disabled and added authorized-key lockout prevention.
- Added secure HashiCorp APT signing-key recovery with a reviewed pinned fingerprint.
- Fixed temporary-file cleanup under `set -u`.
- Restored executable Git modes for operational shell entry points.
- Corrected persistent WireGuard conflict reporting so active `.conf` files are evaluated separately from retained backups.

## v2.1 - Real ZeaZDev environment naming
- Canonical DEV host: `core.zeaz.dev`.
- Canonical PROD host: `prod.zeaz.dev`.
- Desired automation SSH identity: `zeazdev`.
- Removed legacy DBC naming from current automation guidance.
- Preserved the PoliceDBC RouterOS production baseline and safe-change workflow.

## v2.0 - PoliceDBC production-safe refactor
- Replaced clean-slate assumptions with the verified PoliceDBC topology.
- Added hard prechecks for WAN, LAN, default route, and WireGuard.
- Added backup, dry-run, Safe Mode, and explicit live-change gates.
- Deprecated the old PPPoE/192.168.10.0 production assumptions.

## v1.0
- Initial clean-slate PPPoE-oriented design.
