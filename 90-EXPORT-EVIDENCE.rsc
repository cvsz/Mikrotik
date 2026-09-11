:log warning "OMEGA EVIDENCE START"
:put "===== OMEGA EVIDENCE ====="
/system identity print
/system resource print
/ip address print detail
/ip route print detail where dst-address="0.0.0.0/0"
/interface bridge port print
/interface list member print
/ip dhcp-server print detail
/ip dhcp-server network print detail
/interface wireguard print detail
/interface wireguard peers print detail
/ip firewall filter print stats
/ip firewall nat print stats
/ip service print detail
/log print where message~"OMEGA"
/export terse file=omega-policedbc-evidence
:put "EVIDENCE EXPORT CREATED: omega-policedbc-evidence.rsc"
:log warning "OMEGA EVIDENCE COMPLETE"
