:log warning "OMEGA VERIFY START"
:put "===== OMEGA VERIFY ====="
/system resource print
/ip address print
/interface bridge port print
/interface list member print
/ip dhcp-server print detail
/ip dhcp-server lease print detail where mac-address=00:0C:29:75:A6:D4
/interface wireguard print detail
/interface wireguard peers print detail
/ip service print
/ip route print where dst-address="0.0.0.0/0"
:put "PING UPSTREAM"
/ping 192.168.200.1 count=3
:put "PING INTERNET"
/ping 1.1.1.1 count=3
:put "DNS"
:put [/resolve cloudflare.com]
/export terse file=omega-policedbc-after
:put "VERIFY COMPLETE - inspect CORE reachability and WireGuard handshake before exiting Safe Mode"
:log warning "OMEGA VERIFY COMPLETE"
