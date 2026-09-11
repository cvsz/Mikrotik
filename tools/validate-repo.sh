#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail=0
err(){ echo "ERROR: $*" >&2; fail=1; }

required=(
  00-PRECHECK.rsc
  10-BACKUP-SNAPSHOT.rsc
  20-NETWORK-NORMALIZE.rsc
  30-DHCP-DNS-NTP.rsc
  40-WIREGUARD-SERVICES.rsc
  50-FIREWALL-NAT.rsc
  99-VERIFY-HEALTH.rsc
  AGENTS.md README.md ENVIRONMENTS.md
)
for f in "${required[@]}"; do [[ -f "$f" ]] || err "missing required file: $f"; done

# Production-dangerous patterns must not appear in the active v2 phases.
active=(00-PRECHECK.rsc 10-BACKUP-SNAPSHOT.rsc 20-NETWORK-NORMALIZE.rsc 30-DHCP-DNS-NTP.rsc 40-WIREGUARD-SERVICES.rsc 50-FIREWALL-NAT.rsc 99-VERIFY-HEALTH.rsc)
for f in "${active[@]}"; do
  grep -Eiq 'reset-configuration|/ip firewall filter remove \[find\][[:space:]]*$|/ip firewall nat remove \[find\][[:space:]]*$|/ip address remove \[find\][[:space:]]*$|private-key=' "$f" && err "$f contains a prohibited destructive/key pattern"
done

# Canonical topology assertions.
grep -q '192.168.205.251/21' 00-PRECHECK.rsc || err 'precheck missing real WAN IP'
grep -q '192.168.1.1/24' 00-PRECHECK.rsc || err 'precheck missing real LAN gateway'
grep -q '192.168.200.1' 00-PRECHECK.rsc || err 'precheck missing real upstream gateway'
grep -q 'wg-remote' 00-PRECHECK.rsc || err 'precheck missing current WireGuard interface'
grep -q 'core.zeaz.dev' ENVIRONMENTS.md || err 'canonical DEV FQDN missing'
grep -q 'prod.zeaz.dev' ENVIRONMENTS.md || err 'canonical PROD FQDN missing'

if command -v shellcheck >/dev/null 2>&1; then
  mapfile -t shells < <(find tools -type f -name '*.sh' -print)
  ((${#shells[@]} == 0)) || shellcheck "${shells[@]}"
else
  echo 'WARN: shellcheck not installed; shell validation skipped'
fi

(( fail == 0 )) || exit 1
echo 'Repository safety validation PASS'
