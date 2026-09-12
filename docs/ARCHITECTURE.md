# zOS Architecture

## Purpose

zOS is a controller-side safety and automation layer around MikroTik RouterOS. It does not replace RouterOS firmware and does not make GitHub Actions the production network control plane.

## Layers

1. **Inventory** — `config/topology.env` and environment documentation.
2. **Observe** — read-only router/core status, audit, update status, evidence.
3. **Plan** — deterministic `.rsc` phases and explicit change intent.
4. **Validate** — shell/static/topology/document/evidence checks.
5. **Protect** — backup/export, recovery path, Safe Mode, explicit gates.
6. **Apply** — operator-approved idempotent RouterOS changes.
7. **Verify** — independent state/readiness checks.
8. **Package** — tarball and controller-side OCI image via GitHub Actions/GHCR.
9. **Recover** — CORE network/SSH and RouterOS disaster-recovery procedures.

## Trust boundaries

| Boundary | Trust assumption | Required control |
|---|---|---|
| Operator workstation | may hold SSH private keys | key protection; no private keys in repo |
| CORE controller | privileged network automation | key-only SSH, least privilege, route invariants |
| MikroTik RouterOS | production network authority | backup, Safe Mode/recovery, explicit apply |
| GitHub-hosted Actions | unprivileged validation/build | no live production credentials or apply |
| Self-hosted `zOS-Runner` | privileged local automation surface | trusted workloads only; single listener |
| GHCR | distribution of controller image | package permissions and immutable release references |

## Core data flow

~~~text
operator -> GitHub PR/CI -> reviewed repository
operator -> CORE controller -> RouterOS management interface
CORE -> backup/evidence -> protected operator storage
GitHub build -> GHCR controller image
~~~

CI validates source; it does not certify live router state. Live apply remains an operator action from a recovery-capable context.

## Network invariant

~~~text
CORE ens33     -> 192.168.1.0/24 and default via 192.168.1.1
CORE policedbc -> 10.8.0.0/24
Router LAN     -> 192.168.1.1/24
Router WG      -> 10.8.0.1/24
~~~

The same physical LAN CIDR must not be routed into the CORE WireGuard peer.

## Failure model

zOS assumes that configuration drift, runner failures, transient DHCP addresses, stale repository metadata, and human/operator errors can occur. Controls therefore favor explicit state inspection, reversible changes, independent verification, and durable documentation over one-click mutation.
