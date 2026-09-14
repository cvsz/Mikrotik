:log warning "OMEGA NETWORK NORMALIZE START"
:if ([:len [/interface bridge find where name="bridgeLocal"]] = 0) do={ :error "NETWORK NORMALIZE FAIL: bridgeLocal missing" }
:foreach p in={"ether2";"ether3";"ether4";"ether5";"ether6";"ether7";"ether8";"ether9";"ether10";"sfp-sfpplus1"} do={
    :if ([:len [/interface find where name=$p]] > 0) do={
        :if ([:len [/interface bridge port find where bridge="bridgeLocal" and interface=$p]] = 0) do={
            :if ([:len [/interface bridge port find where interface=$p]] > 0) do={ :error ("NETWORK NORMALIZE FAIL: " . $p . " belongs to another bridge") }
            /interface bridge port add bridge=bridgeLocal interface=$p comment="OMEGA-MANAGED"
        }
    }
}
:foreach p in=[/interface bridge port find where interface="ether1"] do={ /interface bridge port remove $p }
:if ([:len [/ip address find where address="192.168.1.1/24" and interface="bridgeLocal"]] = 0) do={ /ip address add address=192.168.1.1/24 interface=bridgeLocal comment="OMEGA-MANAGED LAN gateway" }
:foreach c in=[/ip dhcp-client find where interface!="ether1"] do={
    :if ([/ip dhcp-client get $c comment]~"OMEGA-MANAGED") do={ /ip dhcp-client remove $c }
}
:if ([:len [/ip dhcp-client find where interface="ether1"]] = 0) do={
    /ip dhcp-client add interface=ether1 add-default-route=yes default-route-distance=1 use-peer-dns=yes use-peer-ntp=yes disabled=no comment="OMEGA-MANAGED WAN DHCP"
} else={
    /ip dhcp-client set [find where interface="ether1"] add-default-route=yes default-route-distance=1 disabled=no
}
/interface list
:if ([:len [find where name="WAN"]] = 0) do={ add name=WAN }
:if ([:len [find where name="LAN"]] = 0) do={ add name=LAN }
:if ([:len [find where name="VPN"]] = 0) do={ add name=VPN }
/interface list member
:foreach m in=[find where interface="bridgeLocal" and list="WAN"] do={ remove $m }
:foreach m in=[find where interface="ether1" and list="LAN"] do={ remove $m }
:if ([:len [find where list="WAN" and interface="ether1"]] = 0) do={ add list=WAN interface=ether1 comment="OMEGA-MANAGED" }
:if ([:len [find where list="LAN" and interface="bridgeLocal"]] = 0) do={ add list=LAN interface=bridgeLocal comment="OMEGA-MANAGED" }
:if ([:len [/interface wireguard find where name="wg-remote"]] > 0 && [:len [find where list="VPN" and interface="wg-remote"]] = 0) do={ add list=VPN interface=wg-remote comment="OMEGA-MANAGED" }
:put "NETWORK NORMALIZE PASS"
:log warning "OMEGA NETWORK NORMALIZE PASS"
