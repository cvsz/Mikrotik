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
  60-OBSERVABILITY.rsc
  90-EXPORT-EVIDENCE.rsc
  99-VERIFY-HEALTH.rsc
)

mode="${1:-dry-run}"
STATE_DIR="${OMEGA_STATE_DIR:-$ROOT/state/deploy}"
DRY_RUN_MARKER="$STATE_DIR/dry-run.success"

phase_manifest() {
  local f
  for f in "${PHASES[@]}"; do
    sha256sum "$ROOT/$f"
  done
}

record_dry_run_success() {
  mkdir -p "$STATE_DIR"
  {
    printf 'completed_at=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    phase_manifest
  } > "$DRY_RUN_MARKER"
  chmod 600 "$DRY_RUN_MARKER"
}

dry_run_is_current() {
  [[ -s "$DRY_RUN_MARKER" ]] || return 1
  local expected actual
  expected="$(mktemp)"
  actual="$(mktemp)"
  trap 'rm -f "$expected" "$actual"' RETURN
  phase_manifest > "$expected"
  sed -n '/^[0-9a-f]\{64\} /p' "$DRY_RUN_MARKER" > "$actual"
  cmp -s "$expected" "$actual"
}

require_flag() {
  local name="$1" value="${!1:-0}"
  [[ "$value" == 0 || "$value" == 1 ]] || { echo "$name must be 0 or 1 (got: $value)" >&2; exit 2; }
}

case "$mode" in
  dry-run)
    "$CTL" status
    "$CTL" backup
    for f in "${PHASES[@]}"; do
      echo "===== DRY RUN $f ====="
      "$CTL" dry-run "$ROOT/$f"
    done
    record_dry_run_success
    echo "All dry-runs finished successfully. RouterOS configuration was not imported."
    ;;
  apply)
    require_flag OMEGA_REQUIRE_DRY_RUN
    require_flag OMEGA_REQUIRE_SAFE_MODE
    [[ "${OMEGA_ALLOW_LIVE_APPLY:-0}" == "1" ]] || {
      echo 'Apply blocked. Set OMEGA_ALLOW_LIVE_APPLY=1 only for an approved change window.' >&2
      exit 3
    }
    if [[ "${OMEGA_REQUIRE_DRY_RUN:-1}" == "1" ]]; then
      dry_run_is_current || {
        echo 'Apply blocked: no successful dry-run exists for the exact current phase files.' >&2
        echo 'Run make dry-run again after every phase change.' >&2
        exit 3
      }
    fi
    "$CTL" backup
    if [[ "${OMEGA_REQUIRE_SAFE_MODE:-1}" == "1" ]]; then
      echo 'Starting one interactive RouterOS Safe Mode session for all production imports.'
      "$CTL" apply-safe "${PHASES[@]/#/$ROOT/}"
    else
      for f in "${PHASES[@]}"; do
        echo "===== APPLY $f ====="
        "$CTL" apply "$ROOT/$f"
      done
    fi
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
