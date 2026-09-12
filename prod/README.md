# PROD Host

Canonical PROD endpoint: `prod.zeaz.dev`.

## Verified address

~~~text
PROD_LAN_IP=192.168.1.122
~~~

The LAN address is now part of the production inventory. WireGuard address/interface and production gateway remain unknown until they are observed on the host; do not infer them from the DEV/CORE machine.

## Safety posture

- public-key SSH only is the target state;
- password login remains disabled by default;
- live deployment remains disabled by default;
- unknown network values stay empty;
- do not copy CORE WireGuard assumptions to PROD without runtime evidence.

Use `prod/.env.example` as a reference only. It is not auto-loaded and must never contain credentials or private keys.

## Read-only discovery before bootstrap

Run on PROD before creating any production installer profile:

~~~bash
hostnamectl
ip -br link
ip -br addr
ip route
ip rule
resolvectl status 2>/dev/null || true
wg show 2>/dev/null || true
ss -lntup
lsblk -f
df -hT
free -h
uname -a
cat /etc/os-release
~~~

Sanitize credentials/secrets before retaining output as evidence.
