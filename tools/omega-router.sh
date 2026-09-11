#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${OMEGA_ENV_FILE:-$ROOT/config/topology.env}"
[[ -f "$ENV_FILE" ]] || ENV_FILE="$ROOT/config/topology.env.example"
# shellcheck disable=SC1090
source "$ENV_FILE"

SSH_OPTS=(-o BatchMode=yes -o ConnectTimeout=8 -o ServerAliveInterval=20 -o ServerAliveCountMax=3)
TARGET="${ROUTER_SSH_USER}@${ROUTER_HOST}"

usage() {
  cat <<'EOF'
Usage: tools/omega-router.sh <command> [args]

Commands:
  status                 Read-only router status
  audit                  Read-only full audit
  backup                 Export + binary backup, then download export
  upload <file.rsc>      Upload an RSC only
  dry-run <file.rsc>     Upload and RouterOS dry-run import
  apply <file.rsc>       Apply only when OMEGA_ALLOW_LIVE_APPLY=1
  verify                 Run read-only post-change verification
  fetch-export <name>    Download <name>.rsc from router
EOF
}

ssh_mt() { ssh "${SSH_OPTS[@]}" "$TARGET" "$@"; }

status() {
  ssh_mt '/system identity print; /system resource print; /ip address print; /ip route print where dst-address="0.0.0.0/0"; /interface wireguard peers print detail'
}

audit() {
  ssh_mt '/system identity print; /system resource print; /interface print; /interface bridge port print; /interface list member print; /ip address print detail; /ip route print detail; /ip dhcp-server print detail; /ip dhcp-server network print detail; /ip dhcp-server lease print detail; /interface wireguard print detail; /interface wireguard peers print detail; /ip firewall filter print detail; /ip firewall nat print detail; /ip service print detail; /log print'
}

backup() {
  local stamp name
  stamp="$(date +%Y%m%d-%H%M%S)"
  name="omega-policedbc-$stamp"
  mkdir -p "$ROOT/backups"
  ssh_mt "/export terse file=$name; /system backup save name=$name dont-encrypt=yes"
  scp "${SSH_OPTS[@]}" "$TARGET:$name.rsc" "$ROOT/backups/$name.rsc"
  echo "Saved $ROOT/backups/$name.rsc"
  echo "Binary backup remains on router as $name.backup"
}

upload() {
  local file="$1"
  [[ -f "$file" ]] || { echo "File not found: $file" >&2; exit 2; }
  [[ "$file" == *.rsc ]] || { echo "Only .rsc files are supported" >&2; exit 2; }
  scp "${SSH_OPTS[@]}" "$file" "$TARGET:$(basename "$file")"
}

dry_run() {
  local file="$1" remote
  remote="$(basename "$file")"
  upload "$file"
  ssh_mt "/import file-name=$remote verbose=yes dry-run"
}

apply_file() {
  local file="$1" remote
  [[ "${OMEGA_ALLOW_LIVE_APPLY:-0}" == "1" ]] || {
    echo "Live apply blocked. Set OMEGA_ALLOW_LIVE_APPLY=1 only after backup, dry-run and Safe Mode." >&2
    exit 3
  }
  remote="$(basename "$file")"
  upload "$file"
  ssh_mt "/import file-name=$remote verbose=yes"
}

verify() {
  ssh_mt '/system resource print; /ip address print; /ip route print where dst-address="0.0.0.0/0"; /interface wireguard print detail; /interface wireguard peers print detail; /ip service print; /ping 192.168.200.1 count=3; /ping 1.1.1.1 count=3; :put [/resolve cloudflare.com]'
}

case "${1:-}" in
  status) status ;;
  audit) audit ;;
  backup) backup ;;
  upload) [[ $# -eq 2 ]] || { usage; exit 2; }; upload "$2" ;;
  dry-run) [[ $# -eq 2 ]] || { usage; exit 2; }; dry_run "$2" ;;
  apply) [[ $# -eq 2 ]] || { usage; exit 2; }; apply_file "$2" ;;
  verify) verify ;;
  fetch-export) [[ $# -eq 2 ]] || { usage; exit 2; }; mkdir -p "$ROOT/backups"; scp "${SSH_OPTS[@]}" "$TARGET:$2.rsc" "$ROOT/backups/$2.rsc" ;;
  *) usage; exit 2 ;;
esac
