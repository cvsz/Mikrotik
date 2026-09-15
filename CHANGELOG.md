# Changelog

Notable repository and operational changes are recorded here. zOS has not yet declared a stable public API; version numbers below describe repository milestones.

## Unreleased

### Cloudflare integration boundary
- Added a secret-free Cloudflare connector/origin template and documented the optional DNS, Access, and Tunnel trust boundary.
- Added explicit repository, runtime, rollback, and GitHub review gates; no Cloudflare provisioning or live RouterOS mutation is included.

### Verified RB4011 production topology
- Replaced the stale static-WAN assumption with the verified `ether1` DHCP WAN contract; the observed `192.168.202.91/21` lease is runtime evidence only.
- Made `bridgeLocal = 192.168.1.1/24` the canonical LAN bridge and retained `ether2`-`ether10` plus `sfp-sfpplus1` as LAN ports.
- Added verified DHCP reservations for PoliceDBC-SEA, HA-A, HA-B, and PROD; reserved `core.zeaz.dev = 192.168.1.123` pending a verified CORE MAC.
- Added split/local DNS for `prod.zeaz.dev`, `core.zeaz.dev`, `ha-a.zeaz.dev`, and `ha-b.zeaz.dev`.
- Added `reinstall/OMEGA-RB4011-GOLDEN-REINSTALL.rsc` as the clean rebuild/recovery source of truth.
- Removed obsolete numbered legacy phases for clean-slate identity, PPPoE networking, unverified segmentation, alternate WireGuard, fixed shaping, and superseded logging.

### Production safety hardening
- Added exact SHA-256 dry-run manifests and blocks live apply when phase contents have changed since the successful dry-run.
- Added one-session RouterOS Safe Mode apply with explicit Safe Mode and all-phase success sentinels.
- Added AES-SHA256 controller-managed binary backups, local backup-password protection, download verification flow, and router-side temporary-file cleanup.
- Made dry-run uploads unique and removes temporary files after validation.
- Made RouterOS update checks read-only with respect to update-channel state and requires the running RouterOS version to change before reporting an update successful.
- Changed network, DHCP/DNS, firewall, and NAT management to preserve unowned state and fail closed on ownership conflicts.
- Added an explicit SSH public-key bootstrap helper and isolated RouterOS safety lab test plan.

### Documentation and GitHub operations
- Rebuilt the project documentation map and added architecture, installation, testing, release, network-recovery, SSH-hardening, GitHub-operations, roadmap, support, governance, maintainer, and licensing guidance.
- Added GitHub community templates and CODEOWNERS guidance.
- Added documentation validation to prevent stale repository names and broken local Markdown references.
- Clarified the difference between desired automation identity and the actual operator/recovery account on an existing CORE host.
- Added root, CORE, zOS, PROD, topology, and Windows runner VM `.env.example` templates with fail-closed defaults and documented loading/secret-handling rules.
- Added the `zeaz` Windows VM / `zOS-Runner` environment contract and runner-local documentation.

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
