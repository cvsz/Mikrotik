############################################
# DEPRECATED - DO NOT RUN ON PoliceDBC
############################################
# This historical script assumed a destructive clean-slate PPPoE topology.
# PoliceDBC production uses:
# - WAN ether1 192.168.205.251/21
# - gateway 192.168.200.1
# - LAN bridge-lan 192.168.1.1/24
# - WireGuard wg-remote 10.8.0.1/24
#
# Use the production-safe phase scripts instead:
# 00-PRECHECK.rsc
# 10-BACKUP-SNAPSHOT.rsc
# 20-NETWORK-NORMALIZE.rsc
# 30-DHCP-DNS-NTP.rsc
# 40-WIREGUARD-SERVICES.rsc
# 50-FIREWALL-NAT.rsc
# 99-VERIFY-HEALTH.rsc
#
#error "DEPRECATED: use production-safe OMEGA phases; do not run clean-all one-click on PoliceDBC"
