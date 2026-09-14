#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail=0
err(){ echo "ERROR: $*" >&2; fail=1; }

required=(
  00-PRECHECK.rsc 10-BACKUP-SNAPSHOT.rsc 20-NETWORK-NORMALIZE.rsc
  30-DHCP-DNS-NTP.rsc 40-WIREGUARD-SERVICES.rsc 50-FIREWALL-NAT.rsc
  60-OBSERVABILITY.rsc 90-EXPORT-EVIDENCE.rsc 99-VERIFY-HEALTH.rsc
  reinstall/OMEGA-RB4011-GOLDEN-REINSTALL.rsc
  AGENTS.md README.md CHANGELOG.md CHECKLIST.md CONTRIBUTING.md SECURITY.md
  CODE_OF_CONDUCT.md GOVERNANCE.md MAINTAINERS.md SUPPORT.md ENVIRONMENTS.md
  docs/INDEX.md docs/ARCHITECTURE.md docs/INSTALLATION.md docs/RUNBOOK.md
  docs/NETWORK-RECOVERY.md docs/SSH-HARDENING.md docs/DISASTER-RECOVERY.md
  docs/PRODUCTION-READINESS.md docs/GITHUB-OPERATIONS.md docs/GITHUB-SETTINGS.md
  docs/TESTING.md docs/RELEASES.md docs/ROADMAP.md docs/LICENSING.md
  .github/PULL_REQUEST_TEMPLATE.md .github/CODEOWNERS
  .env.example core/.env.example zOS/.env.example runner/.env.example prod/.env.example config/topology.env.example
  runner/README.md prod/README.md tools/validate-docs.py tools/omega-router.sh tools/deploy-phases.sh
  tools/core-network-repair.sh tools/routeros-auto-update.sh tools/e2e-check.sh
  tools/install-controller.sh tools/install-update-monitor.sh core/install.sh core/README.md
  zOS/README.md zOS/VERSION zOS/Dockerfile zOS/bin/zos zOS/install.sh
  .github/workflows/validate.yml .github/workflows/zos-build.yml
)
for f in "${required[@]}"; do [[ -f "$f" ]] || err "missing required file: $f"; done

executables=(core/install.sh tools/validate-repo.sh tools/omega-router.sh tools/deploy-phases.sh tools/core-network-repair.sh tools/routeros-auto-update.sh tools/e2e-check.sh tools/install-controller.sh tools/install-update-monitor.sh zOS/bin/zos zOS/install.sh)
for f in "${executables[@]}"; do [[ ! -f "$f" || -x "$f" ]] || err "operational entry point is not executable: $f"; done

active=(00-PRECHECK.rsc 10-BACKUP-SNAPSHOT.rsc 20-NETWORK-NORMALIZE.rsc 30-DHCP-DNS-NTP.rsc 40-WIREGUARD-SERVICES.rsc 50-FIREWALL-NAT.rsc 60-OBSERVABILITY.rsc 90-EXPORT-EVIDENCE.rsc 99-VERIFY-HEALTH.rsc)
for f in "${active[@]}"; do
  if grep -Eiq 'reset-configuration|/ip firewall filter remove \[find\][[:space:]]*$|/ip firewall nat remove \[find\][[:space:]]*$|/ip address remove \[find\][[:space:]]*$|private-key=' "$f"; then
    err "$f contains a prohibited destructive/key pattern"
  fi
done

grep -q 'bridgeLocal' 00-PRECHECK.rsc || err 'precheck missing verified LAN bridge'
grep -q 'interface="ether1" and status="bound"' 00-PRECHECK.rsc || err 'precheck missing DHCP WAN bound check'
grep -q '192.168.1.1/24' 00-PRECHECK.rsc || err 'precheck missing LAN gateway'
grep -q '192.168.200.1' 00-PRECHECK.rsc || err 'precheck missing upstream gateway'
grep -q '^ROUTER_WAN_MODE=dhcp$' config/topology.env.example || err 'topology must declare DHCP WAN'
grep -q '^ROUTER_WAN_INTERFACE=ether1$' config/topology.env.example || err 'topology must declare ether1 WAN'
grep -q '^ROUTER_LAN_BRIDGE=bridgeLocal$' config/topology.env.example || err 'topology must declare bridgeLocal LAN'
grep -q '^DEV_LAN_IP=192\.168\.1\.123$' config/topology.env.example || err 'CORE target address missing'
grep -q '^PROD_LAN_IP=192\.168\.1\.122$' config/topology.env.example || err 'PROD LAN address missing'
grep -q '^PROD_LAN_MAC=00:0C:29:B5:F4:09$' config/topology.env.example || err 'PROD MAC missing'
grep -q '48:4D:7E:D4:3A:C6' 30-DHCP-DNS-NTP.rsc || err 'PoliceDBC reservation missing'
grep -q '00:0C:29:B7:22:AF' 30-DHCP-DNS-NTP.rsc || err 'HA-A reservation missing'
grep -q '00:0C:29:72:EF:42' 30-DHCP-DNS-NTP.rsc || err 'HA-B reservation missing'
grep -q '00:0C:29:B5:F4:09' 30-DHCP-DNS-NTP.rsc || err 'PROD reservation missing'
grep -q 'core.zeaz.dev' 30-DHCP-DNS-NTP.rsc || err 'CORE DNS record missing'
grep -q '^PROD_ALLOW_PASSWORD=no$' prod/.env.example || err 'PROD SSH password authentication must fail closed in template'
grep -q '^PROD_ALLOW_DEPLOY=0$' prod/.env.example || err 'PROD live deploy must fail closed in template'
grep -q '^OMEGA_ALLOW_LIVE_APPLY=0$' .env.example || err 'root .env.example must fail closed for live apply'
grep -q '^OMEGA_AUTO_ROUTEROS_UPDATE=0$' .env.example || err 'root .env.example must fail closed for auto update'
grep -q '^OMEGA_ALLOW_ROUTER_REBOOT=0$' .env.example || err 'root .env.example must fail closed for router reboot'
grep -q '^SSH_ALLOW_PASSWORD=no$' core/.env.example || err 'core/.env.example must disable SSH password authentication by default'
grep -q '^OMEGA_ALLOW_LIVE_APPLY=0$' zOS/.env.example || err 'zOS/.env.example must fail closed for live apply'
grep -q '^RUNNER_VM_HOSTNAME=zeaz$' runner/.env.example || err 'runner VM hostname contract missing'
grep -q '^RUNNER_NAME=zOS-Runner$' runner/.env.example || err 'runner name contract missing'
grep -q '^RUNNER_ALLOW_UNTRUSTED_FORKS=0$' runner/.env.example || err 'runner env must reject untrusted forks by default'
grep -q '^RUNNER_ALLOW_LIVE_ROUTEROS_APPLY=0$' runner/.env.example || err 'runner env must block live RouterOS apply by default'
grep -q '^ROUTEROS_UPDATE_CHANNEL=stable$' config/topology.env.example || err 'stable RouterOS update channel missing'
grep -q '^OMEGA_AUTO_ROUTEROS_UPDATE=0$' config/topology.env.example || err 'safe auto-update default missing'
grep -q '^OMEGA_ALLOW_ROUTER_REBOOT=0$' config/topology.env.example || err 'safe reboot default missing'

if grep -Eiq '192\.168\.205\.251|bridge-lan|core\.zeaz\.internal|192\.168\.1\.128' 00-PRECHECK.rsc 20-NETWORK-NORMALIZE.rsc 30-DHCP-DNS-NTP.rsc config/topology.env.example README.md ENVIRONMENTS.md; then
  err 'active production sources still contain legacy topology values'
fi

if grep -Eiq 'allow-unauthenticated|trusted[[:space:]]*=[[:space:]]*yes|Acquire::AllowInsecureRepositories[[:space:]]*=[[:space:]]*true' core/install.sh; then err 'core/install.sh contains an APT signature-bypass pattern'; fi
grep -Fq "SSH_ALLOW_PASSWORD=\"\${SSH_ALLOW_PASSWORD:-no}\"" core/install.sh || err 'CORE SSH password authentication is not fail-closed by default'
grep -Fq 'D55C0D1AC78A8D8126CB631CFC9CA96ACA026560' core/install.sh || err 'HashiCorp APT signing-key fingerprint is not pinned'
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
