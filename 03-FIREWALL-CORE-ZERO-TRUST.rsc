:log warning "PHASE 03 FIREWALL"
/interface list add name=WAN
/interface list add name=LAN
/interface list member add interface=pppoe-out1 list=WAN
/interface list member add interface=bridge-lan list=LAN
/ip firewall filter
add chain=input connection-state=established,related action=accept
add chain=forward connection-state=established,related action=accept
add chain=input connection-state=invalid action=drop
add chain=forward connection-state=invalid action=drop
add chain=input in-interface-list=LAN action=accept
add chain=forward in-interface-list=LAN out-interface-list=WAN action=accept
add chain=input action=drop
add chain=forward action=drop
/ip firewall nat add chain=srcnat out-interface-list=WAN action=masquerade
:log warning "PHASE 03 DONE"
