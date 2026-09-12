#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PREFIX="${ZOS_PREFIX:-$HOME/.local/share/zos-mikrotik}"
BIN_DIR="${ZOS_BIN_DIR:-$HOME/.local/bin}"

mkdir -p "$PREFIX" "$BIN_DIR"
rsync -a --delete --exclude '.git' "$ROOT/" "$PREFIX/"
chmod +x "$PREFIX/zOS/bin/zos" "$PREFIX/tools/"*.sh
ln -sfn "$PREFIX/zOS/bin/zos" "$BIN_DIR/zos"

if [[ ! -f "$PREFIX/config/topology.env" ]]; then
  cp "$PREFIX/config/topology.env.example" "$PREFIX/config/topology.env"
  chmod 600 "$PREFIX/config/topology.env"
fi

printf 'zOS installed\n  command: %s/zos\n  root: %s\n' "$BIN_DIR" "$PREFIX"
printf 'Run: zos doctor\n'
