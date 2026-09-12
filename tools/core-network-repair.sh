#!/usr/bin/env bash
set -Eeuo pipefail

MODE="${1:-status}"
LAN_IFACE="${LAN_IFACE:-ens33}"
WG_IFACE="${WG_IFACE:-policedbc}"
LAN_CIDR="${LAN_CIDR:-192.168.1.0/24}"
GW="${GW:-192.168.1.1}"

show_state() {
  echo '=== links ==='
  ip -br link
  echo '=== addresses ==='
  ip -br addr
  echo '=== routes ==='
  ip route
  echo '=== route decisions ==='
  ip route get "$GW" || true
  ip route get 1.1.1.1 || true
  echo '=== wireguard ==='
  wg show 2>/dev/null || true
  echo '=== networkd ==='
  networkctl status "$LAN_IFACE" --no-pager 2>/dev/null || true
}

check() {
  show_state
  local carrier=unknown
  [[ -r "/sys/class/net/$LAN_IFACE/carrier" ]] && carrier="$(cat "/sys/class/net/$LAN_IFACE/carrier" 2>/dev/null || true)"
  echo "carrier=$carrier"

  if ip route | grep -qE "^${LAN_CIDR//./\.} dev ${WG_IFACE}([[:space:]]|$)"; then
    echo "ERROR: physical LAN route is incorrectly installed on $WG_IFACE" >&2
    return 10
  fi
  if [[ "$carrier" != "1" ]]; then
    echo "ERROR: $LAN_IFACE has no carrier; fix VMware Bridged/VMnet0 first" >&2
    return 11
  fi
  if ! ip route get "$GW" 2>/dev/null | grep -q "dev $LAN_IFACE"; then
    echo "ERROR: gateway $GW is not routed via $LAN_IFACE" >&2
    return 12
  fi
  echo 'CORE network routing looks structurally correct.'
}

repair_runtime() {
  [[ -r "/sys/class/net/$LAN_IFACE/carrier" ]] || { echo "Missing $LAN_IFACE" >&2; exit 20; }
  [[ "$(cat "/sys/class/net/$LAN_IFACE/carrier" 2>/dev/null || echo 0)" == "1" ]] || {
    echo "Refusing repair: $LAN_IFACE has no carrier. Fix VMware bridge first." >&2
    exit 21
  }

  sudo ip link set "$LAN_IFACE" up
  sudo ip route del "$LAN_CIDR" dev "$WG_IFACE" 2>/dev/null || true
  sudo networkctl reconfigure "$LAN_IFACE" || true
  sudo networkctl renew "$LAN_IFACE" || true
  sleep 4
  show_state

  ip route get "$GW" | grep -q "dev $LAN_IFACE" || {
    echo "Repair incomplete: $GW still not routed via $LAN_IFACE" >&2
    exit 22
  }

  ping -c 3 "$GW"
  ping -c 3 1.1.1.1
  getent hosts cloudflare.com
}

find_persistent_conflict() {
  echo '=== persistent references to physical LAN in WireGuard configuration ==='
  sudo grep -RniE '192\.168\.1\.0/24|AllowedIPs|AllowedIPs[[:space:]]*=' /etc/wireguard 2>/dev/null || true
  echo
  echo 'The physical LAN 192.168.1.0/24 must not be an AllowedIPs route on the CORE policedbc tunnel.'
}

case "$MODE" in
  status) show_state ;;
  check) check ;;
  repair-runtime) repair_runtime ;;
  find-conflict) find_persistent_conflict ;;
  *) echo "Usage: $0 {status|check|repair-runtime|find-conflict}" >&2; exit 2 ;;
esac
