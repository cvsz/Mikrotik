:log warning "PHASE 04 SEGMENTATION"
/interface vlan add name=vlan-wallet vlan-id=10 interface=bridge-lan
/interface vlan add name=vlan-signer vlan-id=20 interface=bridge-lan
/ip address add address=10.10.10.1/24 interface=vlan-wallet
/ip address add address=10.10.20.1/24 interface=vlan-signer
/ip firewall filter add chain=forward src-address=10.10.10.0/24 dst-address=10.10.20.0/24 action=accept
/ip firewall filter add chain=forward src-address=10.10.20.0/24 out-interface-list=WAN action=drop
:log warning "PHASE 04 DONE"
