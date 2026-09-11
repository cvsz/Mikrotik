#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${OMEGA_ENV_FILE:-$ROOT/config/topology.env}"
[[ -f "$ENV_FILE" ]] || ENV_FILE="$ROOT/config/topology.env.example"
# shellcheck disable=SC1090
source "$ENV_FILE"

fail=0
ok(){ printf 'PASS: %s\n' "$*"; }
bad(){ printf 'FAIL: %s\n' "$*" >&2; fail=1; }

printf '=== local repository ===\n'
"$ROOT/tools/validate-repo.sh" && ok 'repository validation' || bad 'repository validation'

printf '\n=== DNS ===\n'
getent ahosts "$DEV_FQDN" >/dev/null 2>&1 && ok "$DEV_FQDN resolves" || bad "$DEV_FQDN does not resolve"
getent ahosts "$PROD_FQDN" >/dev/null 2>&1 && ok "$PROD_FQDN resolves" || bad "$PROD_FQDN does not resolve"

printf '\n=== DEV/CORE local network ===\n'
if [[ "$(hostname -f 2>/dev/null || hostname)" == "$DEV_FQDN" || "$(hostname -s)" == core ]]; then
  "$ROOT/tools/core-network-repair.sh" check && ok 'CORE routing' || bad 'CORE routing'
else
  echo 'SKIP: current host is not identified as CORE'
fi

printf '\n=== router ===\n'
if "$ROOT/tools/omega-router.sh" status >/tmp/omega-router-status.$$ 2>&1; then
  ok "router SSH/status at $ROUTER_HOST"
else
  cat /tmp/omega-router-status.$$ >&2 || true
  bad "router SSH/status at $ROUTER_HOST"
fi
rm -f /tmp/omega-router-status.$$

printf '\n=== production SSH ===\n'
if ssh -o BatchMode=yes -o ConnectTimeout=8 "$PROD_SSH_USER@$PROD_FQDN" 'printf prod-ok' 2>/dev/null | grep -q prod-ok; then
  ok "SSH $PROD_SSH_USER@$PROD_FQDN"
else
  bad "SSH $PROD_SSH_USER@$PROD_FQDN (key/access/DNS/firewall may still need provisioning)"
fi

printf '\n=== internet from this host ===\n'
ping -c 2 -W 2 1.1.1.1 >/dev/null 2>&1 && ok 'internet IP reachability' || bad 'internet IP reachability'
getent hosts cloudflare.com >/dev/null 2>&1 && ok 'DNS resolution' || bad 'DNS resolution'

(( fail == 0 )) || exit 1
printf '\nEND-TO-END CHECK PASS\n'
