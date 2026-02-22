############################################
# ZeaZDev META MASTER ONE-CLICK INSTALLER
# Deterministic / Production / Long-term
############################################

:log warning "ZEAZ META MASTER START"

############################
# 1. CLEAN ALL (HARD RESET STYLE)
############################
/ip firewall filter remove [find]
/ip firewall nat remove [find]
/queue simple remove [find]
/interface bridge port remove [find]
/interface bridge remove [find]
/interface list member remove [find]
/interface list remove [find]
/interface vlan remove [find]
/ip dhcp-server remove [find]
/ip dhcp-server network remove [find]
/ip pool remove [find]
/ip address remove [find]
/interface pppoe-client remove [find]
/interface wireguard remove [find]
/system scheduler remove [find]

############################
# 2. IDENTITY & USER
############################
/system identity set name=zeaz-gateway
/user set admin password=CHANGE_ME_STRONG_PASSWORD

############################
# 3. INTERFACE LISTS
############################
/interface list add name=WAN
/interface list add name=LAN
/interface list member add interface=ether1 list=WAN

############################
# 4. BRIDGE (LAN)
############################
/interface bridge add name=bridge-lan protocol-mode=rstp
:for i from=2 to=10 do={
    /interface bridge port add bridge=bridge-lan interface=("ether".$i)
}
 /interface list member add interface=bridge-lan list=LAN

############################
# 5. LAN IP + DHCP
############################
/ip address add address=192.168.10.1/24 interface=bridge-lan
/ip pool add name=lan-pool ranges=192.168.10.100-192.168.10.200
/ip dhcp-server add name=dhcp-lan interface=bridge-lan address-pool=lan-pool disabled=no
/ip dhcp-server network add address=192.168.10.0/24 gateway=192.168.10.1 dns-server=1.1.1.1,8.8.8.8

############################
# 6. PPPoE (WAN)
############################
/interface pppoe-client add name=pppoe-out1 interface=ether1 \
    user=CHANGE_ME_PPP_USERNAME \
    password=CHANGE_ME_PPP_PASSWORD \
    add-default-route=yes use-peer-dns=yes disabled=no

############################
# 7. NAT
############################
/ip firewall nat add chain=srcnat out-interface=pppoe-out1 action=masquerade

############################
# 8. FIREWALL (ZERO TRUST)
############################
/ip firewall filter
add chain=input connection-state=established,related action=accept
add chain=forward connection-state=established,related action=accept
add chain=input connection-state=invalid action=drop
add chain=forward connection-state=invalid action=drop
add chain=input in-interface-list=LAN action=accept
add chain=forward in-interface-list=LAN out-interface-list=WAN action=accept
add chain=input action=drop comment="DROP INPUT"
add chain=forward action=drop comment="DROP FORWARD"

############################
# 9. BANDWIDTH (1000/500 UNLIMITED)
############################
:foreach r in=[/ip firewall filter find where action=fasttrack-connection] do={
    /ip firewall filter disable $r
}
/queue simple add name="GLOBAL-LIMIT" \
    target=bridge-lan \
    max-limit=950M/475M \
    queue=fq-codel/fq-codel \
    comment="UNLIMITED / ANTI-BUFFERBLOAT"

############################
# 10. GUEST VLAN (VLAN 20)
/interface vlan add name=vlan-guest vlan-id=20 interface=bridge-lan
/ip address add address=192.168.20.1/24 interface=vlan-guest
/ip pool add name=guest-pool ranges=192.168.20.100-192.168.20.200
/ip dhcp-server add name=dhcp-guest interface=vlan-guest address-pool=guest-pool disabled=no
/ip dhcp-server network add address=192.168.20.0/24 gateway=192.168.20.1 dns-server=1.1.1.1
/ip firewall filter add chain=forward in-interface=vlan-guest out-interface-list=LAN action=drop comment="GUEST ISOLATION"
 /ip firewall filter add chain=forward in-interface=vlan-guest out-interface-list=WAN action=accept

############################
# 11. WIREGUARD (ADMIN VPN)
/interface wireguard add name=wg-admin listen-port=51820
/ip address add address=10.99.0.1/24 interface=wg-admin
/ip firewall filter add chain=input protocol=udp dst-port=51820 action=accept
/ip firewall filter add chain=input in-interface=wg-admin action=accept

############################
# 12. HARDEN SERVICES
############################
/ip service
set telnet disabled=yes
set ftp disabled=yes
set www disabled=yes
set api disabled=yes
set api-ssl disabled=yes
set ssh address=192.168.10.0/24
set winbox address=192.168.10.0/24

############################
# 13. MAC & DISCOVERY HARDEN
############################
/tool mac-server set allowed-interface-list=LAN
/tool mac-server mac-winbox set allowed-interface-list=LAN
/ip neighbor discovery-settings set discover-interface-list=LAN

############################
# 14. NTP
############################
/system ntp client set enabled=yes servers=1.1.1.1,8.8.8.8

############################
# DONE
############################
:log warning "ZEAZ META MASTER COMPLETE"
############################################
