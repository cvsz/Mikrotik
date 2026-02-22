:log warning "PHASE 05 WIREGUARD"
/interface wireguard add name=wg-admin listen-port=51820
/ip address add address=10.99.0.1/24 interface=wg-admin
/ip firewall filter add chain=input protocol=udp dst-port=51820 action=accept
/ip firewall filter add chain=input in-interface=wg-admin action=accept
/ip service set winbox address=10.99.0.0/24
/ip service set ssh address=10.99.0.0/24 disabled=no
:log warning "PHASE 05 DONE"
