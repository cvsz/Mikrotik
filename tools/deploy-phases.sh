#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CTL="$ROOT/tools/omega-router.sh"
PHASES=(
  00-PRECHECK.rsc
  10-BACKUP-SNAPSHOT.rsc
  20-NETWORK-NORMALIZE.rsc
  30-DHCP-DNS-NTP.rsc
  40-WIREGUARD-SERVICES.rsc
  50-FIREWALL-NAT.rsc
  99-VERIFY-HEALTH.rsc
)

mode="${1:-dry-run}"
case "$mode" in
  dry-run)
    "$CTL" status
    "$CTL" backup
    for f in "${PHASES[@]}"; do
      echo "===== DRY RUN $f ====="
      "$CTL" dry-run "$ROOT/$f"
    done
    echo 'All dry-runs finished. No production configuration was applied.'
    ;;
  apply)
    [[ "${OMEGA_ALLOW_LIVE_APPLY:-0}" == "1" ]] || {
      echo 'Apply blocked. Set OMEGA_ALLOW_LIVE_APPLY=1 only while RouterOS Safe Mode is active.' >&2
      exit 3
    }
    "$CTL" backup
    for f in "${PHASES[@]}"; do
      echo "===== APPLY $f ====="
      "$CTL" apply "$ROOT/$f"
    done
    "$CTL" verify
    ;;
  verify)
    "$CTL" verify
    ;;
  *)
    echo "Usage: $0 {dry-run|apply|verify}" >&2
    exit 2
    ;;
esac
