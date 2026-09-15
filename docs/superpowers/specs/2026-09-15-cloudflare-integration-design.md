# ZOS Cloudflare Integration Design

**Date:** 2026-09-15
**Status:** Approved architecture

## Goal

Integrate Cloudflare with ZOS without weakening the existing MikroTik/RouterOS fail-closed security boundary. Cloudflare provides DNS/DoH, outbound-only Tunnel connectivity, Zero Trust/Access, and service-edge protection while MikroTik remains authoritative for routing, segmentation, firewalling, NAT, and recovery access.

## Security invariants

- MikroTik remains the authoritative LAN/WAN firewall and router.
- Cloudflare failure must not open ports, relax firewall rules, or bypass segmentation.
- `cloudflared` runs on a Linux host, not RouterOS.
- Cloudflare Tunnel uses outbound-only connectivity; selected origins are not exposed through new inbound NAT rules.
- WireGuard remains an independent recovery/administration path.
- WinBox, WebFig, SSH, API, and other management services are never made publicly reachable by this integration.
- Cloudflare API tokens, tunnel credentials, private keys, passwords, and generated credential files are never committed.
- Configuration changes are guarded by precheck, backup, validation, verification, and documented rollback.
- Existing ZOS RouterOS behavior is preserved unless a change is explicitly required by this design.

## Architecture

Internet traffic intended for published ZOS services terminates at Cloudflare. Cloudflare Tunnel connectors on approved Linux hosts establish outbound connections to Cloudflare and forward only explicitly configured hostnames/routes to internal origins. Cloudflare Access protects administrative web applications where appropriate. RouterOS continues to enforce the network boundary independently of Cloudflare.

DNS clients may use RouterOS as their trusted resolver/cache. RouterOS forwards through Cloudflare DNS-over-HTTPS with certificate verification. DNS service from the router is restricted to trusted LAN/VLAN sources and is denied from WAN.

## Components

### 1. RouterOS Cloudflare DNS/DoH

Add a focused RouterOS stage for Cloudflare DoH. It must preserve bootstrap resolution, enable certificate verification, avoid exposing port 53 to WAN, and include pre/post verification and rollback instructions.

### 2. Linux `cloudflared` runtime

Add a `cloudflare/` module with installation, configuration templates, systemd deployment, optional container deployment, health checks, and uninstall/rollback guidance. Runtime credentials are injected locally through protected files or environment/secret mechanisms and are excluded from Git.

### 3. Cloudflare Tunnel ingress

Publish only explicitly approved internal services. Ingress configuration terminates with a deny/not-found catch-all. No broad LAN publication and no automatic wildcard exposure are allowed.

### 4. Zero Trust and Access

Document and automate where safely possible the policies required to authenticate users before protected administrative applications. Private-network routing is least-privilege and limited to required subnets/services. Device posture can be layered later without becoming a prerequisite for basic recovery.

### 5. Recovery

WireGuard remains independent of Cloudflare. A Cloudflare outage may make Cloudflare-published applications unavailable, but it must not remove LAN operation, RouterOS firewall enforcement, or the independent recovery path.

### 6. Observability and evidence

Extend ZOS observability and evidence collection to cover DoH resolution, connector state, origin reachability, tunnel health, accidental WAN management exposure, secret-file permissions, and rollback evidence.

## Repository layout

Planned additions and targeted updates:

- `35-CLOUDFLARE-DNS.rsc` — RouterOS DoH configuration and guarded checks.
- `cloudflare/README.md` — operator workflow and security model.
- `cloudflare/config.yml.example` — secret-free tunnel ingress template.
- `cloudflare/install-cloudflared.sh` — guarded Linux installer.
- `cloudflare/uninstall-cloudflared.sh` — rollback/removal.
- `cloudflare/healthcheck.sh` — connector/origin checks.
- `cloudflare/docker-compose.yml` — optional connector runtime with no embedded credential.
- `.env.example` — only non-secret variable names/placeholders where needed.
- `.gitignore` — explicitly exclude Cloudflare credential/token material.
- `60-OBSERVABILITY.rsc` — Cloudflare-relevant RouterOS observations where applicable.
- `90-EXPORT-EVIDENCE.rsc` — include DNS/firewall evidence without secrets.
- `99-VERIFY-HEALTH.rsc` — validate DNS and boundary invariants.
- `.github/workflows/...` — static validation and secret/security gates.
- documentation/checklists — deployment, rollback, and release evidence.

Exact existing files are modified only after their current behavior is inspected during implementation.

## Data and traffic flow

For public application traffic: client -> Cloudflare edge -> authenticated/authorized edge policy where configured -> Cloudflare Tunnel -> `cloudflared` -> explicitly configured internal origin. No inbound tunnel port is opened on MikroTik.

For LAN DNS: trusted client -> RouterOS resolver/cache -> Cloudflare DoH -> authoritative DNS. WAN-originated DNS requests to RouterOS remain blocked.

For recovery: administrator -> independent WireGuard path -> management network -> RouterOS/internal systems. This path does not depend on Cloudflare Tunnel.

## Failure behavior

- Cloudflare edge/tunnel outage: published applications may fail closed; firewall/LAN/recovery remain intact.
- `cloudflared` stopped: no fallback to direct WAN publication.
- DoH unavailable: behavior must be explicitly verified before deployment; no silent insecure resolver downgrade is introduced by ZOS automation.
- Invalid credentials: connector fails without exposing an origin.
- Misconfigured ingress: catch-all denies/unroutes unspecified services.
- RouterOS validation failure: stop before apply or use documented rollback from the pre-change backup/export.

## Testing strategy

Testing is layered: static checks for shell/YAML/RouterOS templates and secret leakage; isolated RouterOS safety-lab validation; Linux connector installation and health tests; negative tests proving management ports/DNS are not exposed from WAN; tunnel tests proving only declared origins are reachable; recovery tests proving WireGuard remains independent; and evidence generation sufficient for a reviewer to determine whether the release gate passed.

No test may weaken a security gate merely to obtain a green result.

## Delivery stages

1. Baseline and safety gates.
2. Cloudflare DoH/DNS integration.
3. `cloudflared` Linux runtime.
4. Tunnel ingress and explicit service publication.
5. Zero Trust/Access and private routing where required.
6. Observability, rollback, and evidence.
7. CI/security/release gates.
8. Isolated lab validation.
9. Guarded production deployment only after evidence review.

## Definition of done

The integration is complete only when configuration is reproducible and secret-free in Git; RouterOS continues to fail closed; WAN management/DNS exposure tests pass; Cloudflare DoH is verified; selected Tunnel origins work without inbound NAT publication; Access protects designated applications; independent WireGuard recovery is verified; rollback is tested; CI/security checks are green; deployment evidence is recorded; documentation matches the verified topology; and no Critical/High release blocker remains.

Passing repository checks alone does not constitute proof that a live MikroTik or Cloudflare account is production-ready. Live readiness requires environment-specific validation and recorded evidence.