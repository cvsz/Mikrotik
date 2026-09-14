#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  cat <<'EOF'
Usage: core/install-ssh-key.sh --host HOST --user USER --private-key PATH [--port PORT]

Validate a private key locally, derive and fingerprint its public key, then use
ssh-copy-id to append only that public key to the target user's authorized_keys.
The target is always explicit; this script never contains a fixed host address.
EOF
}

HOST=""
USER_NAME=""
PRIVATE_KEY=""
PORT="22"

while (($#)); do
  case "$1" in
    --host) HOST="${2:-}"; shift 2 ;;
    --user) USER_NAME="${2:-}"; shift 2 ;;
    --private-key) PRIVATE_KEY="${2:-}"; shift 2 ;;
    --port) PORT="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

[[ -n "$HOST" && -n "$USER_NAME" && -n "$PRIVATE_KEY" ]] || { usage >&2; exit 2; }
[[ -f "$PRIVATE_KEY" ]] || { echo "Private key not found: $PRIVATE_KEY" >&2; exit 2; }
[[ "$HOST" != -* && "$USER_NAME" != -* ]] || { echo 'Host/user may not start with -' >&2; exit 2; }
[[ "$PORT" =~ ^[0-9]+$ && "$PORT" -ge 1 && "$PORT" -le 65535 ]] || { echo 'Port must be 1-65535' >&2; exit 2; }

command -v ssh-keygen >/dev/null 2>&1 || { echo 'ssh-keygen is required' >&2; exit 1; }
command -v ssh-copy-id >/dev/null 2>&1 || { echo 'ssh-copy-id is required' >&2; exit 1; }

umask 077
TMP_DIR="$(mktemp -d)"
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

PUBLIC_KEY="$TMP_DIR/id.pub"
ssh-keygen -y -f "$PRIVATE_KEY" > "$PUBLIC_KEY"
chmod 600 "$PUBLIC_KEY"
ssh-keygen -lf "$PUBLIC_KEY" >/dev/null
ssh-keygen -lf "$PUBLIC_KEY" -E sha256

TARGET="$USER_NAME@$HOST"
echo "Installing validated public key on $TARGET (port $PORT)."
echo 'The private key remains local and is never transmitted.'
ssh-copy-id -i "$PUBLIC_KEY" -p "$PORT" "$TARGET"

echo 'SSH key installation completed. Verify key-only authentication before disabling any recovery access.'
