#!/usr/bin/env bash
set -Eeuo pipefail

# zOS DEV/CORE bootstrap: repair the known LAN/WireGuard route conflict and
# bring OpenSSH up without making destructive persistent network changes.
#
# Supported target: Ubuntu/Debian systemd host (canonical CORE: core.zeaz.dev).
# Canonical defaults can be overridden with environment variables.

LAN_IFACE="${LAN_IFACE:-ens33}"
WG_IFACE="${WG_IFACE:-policedbc}"
LAN_CIDR="${LAN_CIDR:-192.168.1.0/24}"
GW="${GW:-192.168.1.1}"
SSH_PORT="${SSH_PORT:-22}"
SSH_ALLOW_PASSWORD="${SSH_ALLOW_PASSWORD:-yes}"
SSH_USER="${SSH_USER:-${SUDO_USER:-${USER:-zeazdev}}}"
SSH_DROPIN="/etc/ssh/sshd_config.d/99-zeaz-core.conf"

log() { printf '\n==> %s\n' "$*"; }
warn() { printf '\nWARNING: %s\n' "$*" >&2; }
die() { printf '\nERROR: %s\n' "$*" >&2; exit 1; }

repair_hashicorp_apt_key() {
  local url key_ascii keyring_tmp keyring source_file codename arch
  url="https://apt.releases.hashicorp.com/gpg"
  keyring="/usr/share/keyrings/hashicorp-archive-keyring.gpg"
  key_ascii="$(mktemp)"
  keyring_tmp="$(mktemp)"
  trap 'rm -f "${key_ascii:-}" "${keyring_tmp:-}"; trap - RETURN' RETURN

  command -v gpg >/dev/null 2>&1 || {
    warn "HashiCorp APT signing key is stale/missing, but gpg is unavailable."
    warn "Install gnupg from Ubuntu sources or repair the repository manually before rerunning."
    return 1
  }

  log "Refreshing the official HashiCorp APT signing key"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL --proto '=https' --tlsv1.2 "$url" -o "$key_ascii"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$key_ascii" "$url"
  else
    warn "Neither curl nor wget is available to retrieve the HashiCorp signing key."
    return 1
  fi

  gpg --batch --yes --dearmor --output "$keyring_tmp" "$key_ascii"
  gpg --batch --show-keys "$keyring_tmp" >/dev/null 2>&1 || {
    warn "Downloaded HashiCorp key material is not a valid OpenPGP public key."
    return 1
  }

  install -d -m 0755 /usr/share/keyrings
  install -m 0644 "$keyring_tmp" "$keyring"

  # Official HashiCorp Debian guidance uses this keyring through signed-by.
  # Preserve an already-correct source. If the common hashicorp.list exists but
  # lacks signed-by, back it up and normalize only that HashiCorp source file.
  source_file="/etc/apt/sources.list.d/hashicorp.list"
  if [[ -f "$source_file" ]] &&
     grep -q 'apt\.releases\.hashicorp\.com' "$source_file" &&
     ! grep -q 'signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg' "$source_file"; then
    cp -a "$source_file" "${source_file}.bak.$(date +%Y%m%d-%H%M%S)"
    # shellcheck disable=SC1091
    source /etc/os-release
    codename="${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}"
    arch="$(dpkg --print-architecture)"
    [[ -n "$codename" ]] || {
      warn "Cannot determine Ubuntu/Debian codename; leaving the existing HashiCorp source unchanged."
      return 1
    }
    printf 'deb [arch=%s signed-by=%s] https://apt.releases.hashicorp.com %s main\n' \
      "$arch" "$keyring" "$codename" >"$source_file"
    chmod 0644 "$source_file"
  fi

  echo "HashiCorp APT key refreshed: $keyring"
}

apt_update_safe() {
  local logfile
  logfile="$(mktemp)"

  if apt-get update 2>&1 | tee "$logfile"; then
    rm -f "$logfile"
    return 0
  fi

  if grep -q 'apt\.releases\.hashicorp\.com' "$logfile" &&
     grep -qE 'NO_PUBKEY|signatures couldn.t be verified|repository .* is not signed' "$logfile"; then
    warn "APT update failed because the configured HashiCorp repository signing key is missing or stale."
    repair_hashicorp_apt_key || {
      rm -f "$logfile"
      die "Unable to repair the HashiCorp APT signing key securely."
    }
    rm -f "$logfile"
    log "Retrying APT update after HashiCorp key refresh"
    apt-get update
    return 0
  fi

  warn "APT update failed for a reason not covered by the safe repository repair path."
  warn "No APT signature checks were bypassed and no third-party repository was disabled."
  rm -f "$logfile"
  return 1
}

if [[ "${EUID}" -ne 0 ]]; then
  if command -v sudo >/dev/null 2>&1; then
    exec sudo --preserve-env=LAN_IFACE,WG_IFACE,LAN_CIDR,GW,SSH_PORT,SSH_ALLOW_PASSWORD,SSH_USER bash "$0" "$@"
  fi
  die "Run as root (or install sudo)."
fi

[[ "$(uname -s)" == "Linux" ]] || die "Linux is required."
command -v apt-get >/dev/null 2>&1 || die "apt-get is required (Ubuntu/Debian target)."
command -v systemctl >/dev/null 2>&1 || die "systemd/systemctl is required."
command -v ip >/dev/null 2>&1 || {
  apt_update_safe
  DEBIAN_FRONTEND=noninteractive apt-get install -y iproute2
}

log "Detecting CORE network state"
[[ -d "/sys/class/net/$LAN_IFACE" ]] || die "LAN interface '$LAN_IFACE' does not exist. Override LAN_IFACE if needed."

carrier="unknown"
if [[ -r "/sys/class/net/$LAN_IFACE/carrier" ]]; then
  carrier="$(cat "/sys/class/net/$LAN_IFACE/carrier" 2>/dev/null || true)"
fi

primary_addr="$(ip -4 -o addr show dev "$LAN_IFACE" scope global 2>/dev/null | awk 'NR==1 {print $4}')"
printf 'LAN interface : %s\n' "$LAN_IFACE"
printf 'LAN address   : %s\n' "${primary_addr:-none}"
printf 'LAN CIDR      : %s\n' "$LAN_CIDR"
printf 'Gateway       : %s\n' "$GW"
printf 'WG interface  : %s\n' "$WG_IFACE"
printf 'Carrier       : %s\n' "$carrier"

if [[ "$carrier" == "0" ]]; then
  die "$LAN_IFACE has no carrier. Fix VMware Bridged/VMnet0 or the physical link before changing routes."
fi

log "Checking the known physical-LAN/WireGuard route conflict"
if ip -4 route show "$LAN_CIDR" | grep -qE "(^|[[:space:]])dev[[:space:]]+$WG_IFACE([[:space:]]|$)"; then
  warn "$LAN_CIDR is also routed through $WG_IFACE. Removing only that conflicting runtime route."
  ip route del "$LAN_CIDR" dev "$WG_IFACE" 2>/dev/null || true
else
  echo "No $LAN_CIDR route is currently installed through $WG_IFACE."
fi

# Ensure the LAN link is administratively up. We deliberately do not replace the
# default route, assign a static IP, or rewrite persistent network configuration.
ip link set "$LAN_IFACE" up

# Ask networkd to refresh DHCP if it owns the device; tolerate NetworkManager or
# other network managers where networkctl may not manage the link.
if command -v networkctl >/dev/null 2>&1; then
  networkctl reconfigure "$LAN_IFACE" >/dev/null 2>&1 || true
  networkctl renew "$LAN_IFACE" >/dev/null 2>&1 || true
  sleep 2
fi

route_to_gw="$(ip route get "$GW" 2>/dev/null || true)"
printf 'Gateway route  : %s\n' "${route_to_gw:-none}"
if ! grep -qE "(^|[[:space:]])dev[[:space:]]+$LAN_IFACE([[:space:]]|$)" <<<"$route_to_gw"; then
  die "Gateway $GW is not routed through $LAN_IFACE. Refusing to modify SSH until the LAN path is structurally correct."
fi

primary_addr="$(ip -4 -o addr show dev "$LAN_IFACE" scope global 2>/dev/null | awk 'NR==1 {print $4}')"
[[ -n "$primary_addr" ]] || die "$LAN_IFACE has no global IPv4 address after refresh."

log "Installing OpenSSH server"
apt_update_safe
DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server iproute2
install -d -m 0755 /etc/ssh/sshd_config.d

if [[ -f "$SSH_DROPIN" ]]; then
  cp -a "$SSH_DROPIN" "${SSH_DROPIN}.bak.$(date +%Y%m%d-%H%M%S)"
fi

case "${SSH_ALLOW_PASSWORD,,}" in
  yes|true|1) password_auth=yes ;;
  no|false|0) password_auth=no ;;
  *) die "SSH_ALLOW_PASSWORD must be yes/no, true/false, or 1/0." ;;
esac

cat >"$SSH_DROPIN" <<EOF_SSH
# Managed by cvsz/zos core/install.sh
Port $SSH_PORT
AddressFamily any
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication $password_auth
KbdInteractiveAuthentication no
UsePAM yes
EOF_SSH

log "Validating sshd configuration"
/usr/sbin/sshd -t

log "Enabling SSH"
systemctl enable --now ssh
systemctl restart ssh

log "Opening SSH port when UFW is active"
if command -v ufw >/dev/null 2>&1 && ufw status 2>/dev/null | grep -qi '^Status: active'; then
  ufw allow "${SSH_PORT}/tcp"
else
  echo "UFW is not active; no firewall rule changed."
fi

log "Verifying route selection"
route_to_gw="$(ip route get "$GW" 2>/dev/null || true)"
printf '%s\n' "$route_to_gw"
if ! grep -qE "(^|[[:space:]])dev[[:space:]]+$LAN_IFACE([[:space:]]|$)" <<<"$route_to_gw"; then
  die "Gateway $GW is no longer selected through $LAN_IFACE."
fi

if ip -4 route show "$LAN_CIDR" | grep -qE "(^|[[:space:]])dev[[:space:]]+$WG_IFACE([[:space:]]|$)"; then
  die "Conflicting $LAN_CIDR route through $WG_IFACE returned immediately. Fix persistent WireGuard AllowedIPs before continuing."
fi

log "Verifying sshd listener"
if ! ss -ltnp | grep -qE "LISTEN.+:${SSH_PORT}([[:space:]]|$)"; then
  systemctl --no-pager -l status ssh || true
  die "sshd is not listening on TCP/$SSH_PORT."
fi

systemctl --no-pager --full status ssh | sed -n '1,18p'

echo
printf 'Current routes:\n'
ip -4 route

if [[ -d /etc/wireguard ]]; then
  echo
  echo "Persistent conflict check (/etc/wireguard):"
  grep -RniF "$LAN_CIDR" /etc/wireguard 2>/dev/null || true
  grep -RniE 'AllowedIPs[[:space:]]*=' /etc/wireguard 2>/dev/null || true
fi

echo
printf '%s\n' '=============================================================='
printf 'CORE SSH bootstrap complete.\n'
printf '  user : %s\n' "$SSH_USER"
printf '  port : %s\n' "$SSH_PORT"
printf '  IP   : %s\n' "${primary_addr%%/*}"
printf '\nTest from another LAN host:\n'
printf '  ssh -p %q %q@%q\n' "$SSH_PORT" "$SSH_USER" "${primary_addr%%/*}"
printf '\nWindows PowerShell:\n'
printf '  Test-NetConnection %s -Port %s\n' "${primary_addr%%/*}" "$SSH_PORT"
printf '%s\n' '=============================================================='

if [[ "$password_auth" == "yes" ]]; then
  warn "PasswordAuthentication is enabled for bootstrap access. After key login is proven, rerun with SSH_ALLOW_PASSWORD=no to harden SSH."
fi

cat <<'EOF_NOTE'

Persistent network note:
  This installer removes only the conflicting runtime route. It intentionally
  does not rewrite WireGuard, Netplan, NetworkManager, Docker, or systemd-networkd
  configuration. The CORE invariant is:

    default via 192.168.1.1 dev ens33
    192.168.1.0/24 dev ens33
    10.8.0.0/24 dev policedbc

  192.168.1.0/24 must not be present in policedbc WireGuard AllowedIPs.
EOF_NOTE
