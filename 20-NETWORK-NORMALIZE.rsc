:log warning "OMEGA NETWORK NORMALIZE START"
:foreach p in={"ether2";"ether3";"ether4";"ether5";"ether6";"ether7";"ether8";"ether9";"ether10";"sfp-sfpplus1"} do={
    :if ([:len [/interface find where name=$p]] > 0) do={
        :if ([:len [/interface bridge port find where bridge="bridge-lan" and interface=$p]] = 0) do={
            /interface bridge port add bridge=bridge-lan interface=$p comment="OMEGA-MANAGED"
        }
    }
}
:foreach a in=[/ip address find where address="192.168.1.1/24" and interface="ether2"] do={
    /ip address remove $a
    :log warning "OMEGA removed duplicate LAN gateway from ether2"
}
/interface list
:if ([:len [find where name="WAN"]] = 0) do={ add name=WAN }
:if ([:len [find where name="LAN"]] = 0) do={ add name=LAN }
:if ([:len [find where name="VPN"]] = 0) do={ add name=VPN }
/interface list member
:if ([:len [find where list="WAN" and interface="ether1"]] = 0) do={ add list=WAN interface=ether1 comment="OMEGA-MANAGED" }
:if ([:len [find where list="LAN" and interface="bridge-lan"]] = 0) do={ add list=LAN interface=bridge-lan comment="OMEGA-MANAGED" }
:if ([:len [find where list="VPN" and interface="wg-remote"]] = 0) do={ add list=VPN interface=wg-remote comment="OMEGA-MANAGED" }
:put "NETWORK NORMALIZE PASS"
:log warning "OMEGA NETWORK NORMALIZE PASS"
