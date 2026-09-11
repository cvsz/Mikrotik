:log warning "OMEGA WIREGUARD SERVICES START"
/interface wireguard set [find where name="wg-remote"] listen-port=51820 mtu=1420
:if ([:len [/ip address find where address="10.8.0.1/24" and interface="wg-remote"]] = 0) do={
    /ip address add address=10.8.0.1/24 interface=wg-remote comment="PoliceDBC: VPN GATEWAY"
}
:if ([:len [/interface wireguard peers find where interface="wg-remote" and allowed-address="10.8.0.2/32"]] = 0) do={
    :log warning "OMEGA WARNING: expected CORE peer 10.8.0.2/32 not found; keys unchanged"
}
/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set www disabled=yes
/ip service set www-ssl disabled=yes
/ip service set api disabled=yes
/ip service set api-ssl disabled=yes
/ip service set ssh disabled=no port=22
/ip service set winbox disabled=no port=8291
:if ([:len [/ip service find where name="reverse-proxy"]] > 0) do={ /ip service set reverse-proxy disabled=yes }
/ip ssh set strong-crypto=yes
/tool bandwidth-server set enabled=no
/ip proxy set enabled=no
/ip socks set enabled=no
/ip upnp set enabled=no
/tool mac-server set allowed-interface-list=none
/tool mac-server mac-winbox set allowed-interface-list=LAN
/tool mac-server ping set enabled=no
/ip neighbor discovery-settings set discover-interface-list=LAN
:put "WIREGUARD SERVICES PASS"
:log warning "OMEGA WIREGUARD SERVICES PASS"
