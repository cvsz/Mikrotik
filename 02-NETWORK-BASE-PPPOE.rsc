:log warning "PHASE 02 NETWORK BASE"
/interface bridge add name=bridge-lan protocol-mode=rstp
:for i from=2 to=10 do={/interface bridge port add bridge=bridge-lan interface=("ether".$i)}
/ip address add address=192.168.10.1/24 interface=bridge-lan
/ip pool add name=lan-pool ranges=192.168.10.100-192.168.10.200
/ip dhcp-server add name=dhcp-lan interface=bridge-lan address-pool=lan-pool disabled=no
/ip dhcp-server network add address=192.168.10.0/24 gateway=192.168.10.1 dns-server=1.1.1.1,8.8.8.8
/interface pppoe-client add name=pppoe-out1 interface=ether1 user=CHANGE_ME_PPP_USERNAME password=CHANGE_ME_PPP_PASSWORD add-default-route=yes use-peer-dns=yes disabled=no
:log warning "PHASE 02 DONE"
