# Cloudflare integration for zOS

This module integrates Cloudflare with the zOS MikroTik control plane without moving the RouterOS security boundary into Cloudflare.

## Architecture

```text
Internet
  |
Cloudflare DNS / Zero Trust / Access
  |
Cloudflare Tunnel (outbound only)
  |
CORE controller (cloudflared)
  |
MikroTik RB4011 / RouterOS
  |
192.168.1.0/24
```

`cloudflared` runs on CORE or another explicitly approved Linux controller. It is not installed on RouterOS. RouterOS remains responsible for routing, firewall, NAT, DHCP, and local management policy.

## Security invariants

- Do not expose WinBox, WebFig, SSH, or RouterOS API to the public Internet.
- Do not store Cloudflare tunnel tokens, API tokens, credentials, private keys, or generated credentials in Git.
- Cloudflare Tunnel must use outbound connections from an approved controller.
- Cloudflare Access policy is required before publishing administrative applications.
- Tunnel configuration must not change the RouterOS default route, WAN configuration, WireGuard `AllowedIPs`, firewall, or NAT implicitly.
- Existing zOS backup, dry-run, recovery, explicit-operator-approval, and post-change verification requirements remain mandatory.
- Cloudflare failure must not remove local recovery/management access.
- A green repository check does not prove that Cloudflare, DNS, Tunnel, Access, RouterOS, or origin services are healthy in production.

## Recommended deployment

1. Keep RouterOS management reachable only from approved LAN/VPN management networks.
2. Install `cloudflared` on CORE (`core.zeaz.dev`) or a dedicated Linux connector.
3. Create a named Cloudflare Tunnel outside Git and supply credentials through the host secret store/environment.
4. Route only explicitly approved application hostnames to explicitly configured private origins.
5. Protect administrative HTTP applications with Cloudflare Access.
6. Use RouterOS DNS-over-HTTPS only as a separately reviewed configuration change; do not silently replace the current DNS path.
7. Run zOS validation and runtime verification before and after any network-policy change.

## Configuration

Copy `cloudflare/config.env.example` to a local secret/config file and fill only verified site-specific values. Never commit the populated file.

The example intentionally contains no tunnel token, account ID, zone ID, API token, or private credential.

## Scope

This foundation documents and configures the integration boundary. It does **not** claim autonomous Cloudflare provisioning, live RouterOS mutation, or production readiness. Live changes remain operator-gated under `AGENTS.md`.
