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
  60-OBSERVABILITY.rsc
  90-EXPORT-EVIDENCE.rsc
  99-VERIFY-HEALTH.rsc
  AGENTS.md README.md ENVIRONMENTS.md SECURITY.md
  CLAUDE.md GEMINI.md CONTRIBUTING.md
  config/topology.env.example
  tools/omega-router.sh
  tools/deploy-phases.sh
  tools/core-network-repair.sh
  tools/routeros-auto-update.sh
  tools/e2e-check.sh
  tools/install-controller.sh
  tools/install-update-monitor.sh
  core/install.sh core/README.md
  zOS/README.md zOS/VERSION zOS/Dockerfile zOS/bin/zos zOS/install.sh
  .github/workflows/validate.yml
  .github/workflows/zos-build.yml
)
for f in "${required[@]}"; do [[ -f "$f" ]] || err "missing required file: $f"; done

active=(00-PRECHECK.rsc 10-BACKUP-SNAPSHOT.rsc 20-NETWORK-NORMALIZE.rsc 30-DHCP-DNS-NTP.rsc 40-WIREGUARD-SERVICES.rsc 50-FIREWALL-NAT.rsc 60-OBSERVABILITY.rsc 90-EXPORT-EVIDENCE.rsc 99-VERIFY-HEALTH.rsc)
for f in "${active[@]}"; do
  if grep -Eiq 'reset-configuration|/ip firewall filter remove \[find\][[:space:]]*$|/ip firewall nat remove \[find\][[:space:]]*$|/ip address remove \[find\][[:space:]]*$|private-key=' "$f"; then
    err "$f contains a prohibited destructive/key pattern"
  fi
done

grep -q '192.168.205.251/21' 00-PRECHECK.rsc || err 'precheck missing real WAN IP'
grep -q '192.168.1.1/24' 00-PRECHECK.rsc || err 'precheck missing real LAN gateway'
grep -q '192.168.200.1' 00-PRECHECK.rsc || err 'precheck missing real upstream gateway'
grep -q 'wg-remote' 00-PRECHECK.rsc || err 'precheck missing current WireGuard interface'
grep -q 'core.zeaz.dev' ENVIRONMENTS.md || err 'canonical DEV FQDN missing'
grep -q 'prod.zeaz.dev' ENVIRONMENTS.md || err 'canonical PROD FQDN missing'
grep -q '^ROUTEROS_UPDATE_CHANNEL=stable$' config/topology.env.example || err 'stable RouterOS update channel missing'
grep -q '^OMEGA_AUTO_ROUTEROS_UPDATE=0$' config/topology.env.example || err 'safe auto-update default missing'
grep -q '^OMEGA_ALLOW_ROUTER_REBOOT=0$' config/topology.env.example || err 'safe reboot default missing'

if grep -Eiq 'allow-unauthenticated|trusted[[:space:]]*=[[:space:]]*yes|Acquire::AllowInsecureRepositories[[:space:]]*=[[:space:]]*true' core/install.sh; then
  err 'core/install.sh contains an APT signature-bypass pattern'
fi

grep -Fq "SSH_ALLOW_PASSWORD=\"\${SSH_ALLOW_PASSWORD:-no}\"" core/install.sh || err 'CORE SSH password authentication is not fail-closed by default'
grep -Fq 'D55C0D1AC78A8D8126CB631CFC9CA96ACA026560' core/install.sh || err 'current HashiCorp APT signing-key fingerprint is not pinned'
grep -Fq 'Password authentication is disabled by default' core/install.sh || err 'CORE installer lacks authorized_keys lockout prevention'
grep -Fq 'trap - RETURN' core/install.sh || err 'HashiCorp temp cleanup trap is not self-clearing'

if command -v shellcheck >/dev/null 2>&1; then
  mapfile -t shells < <(find tools zOS core -type f \( -name '*.sh' -o -path 'zOS/bin/zos' \) -print)
  (("${#shells[@]}" == 0)) || shellcheck "${shells[@]}"
else
  echo 'WARN: shellcheck not installed; shell validation skipped'
fi

(( fail == 0 )) || exit 1
echo 'Repository safety validation PASS'
