:log warning "OMEGA DHCP DNS NTP START"
:if ([:len [/ip pool find where name="client-dhcp-pool"]] = 0) do={
    /ip pool add name=client-dhcp-pool ranges=192.168.1.50-192.168.1.199
} else={
    /ip pool set [find where name="client-dhcp-pool"] ranges=192.168.1.50-192.168.1.199
}
:if ([:len [/ip dhcp-server find where name="dhcp-client"]] = 0) do={
    /ip dhcp-server add name=dhcp-client interface=bridge-lan address-pool=client-dhcp-pool lease-time=12h disabled=no comment="PoliceDBC: LAN DHCP SERVER"
} else={
    /ip dhcp-server set [find where name="dhcp-client"] interface=bridge-lan address-pool=client-dhcp-pool lease-time=12h disabled=no
}
:foreach s in=[/ip dhcp-server find where interface="ether2"] do={ /ip dhcp-server remove $s }
:foreach n in=[/ip dhcp-server network find where address="0.0.0.0/24"] do={ /ip dhcp-server network remove $n }
:if ([:len [/ip dhcp-server network find where address="192.168.1.0/24"]] = 0) do={
    /ip dhcp-server network add address=192.168.1.0/24 gateway=192.168.1.1 dns-server=192.168.1.1 comment="OMEGA-MANAGED"
} else={
    /ip dhcp-server network set [find where address="192.168.1.0/24"] gateway=192.168.1.1 dns-server=192.168.1.1
}
# CORE exhibited dual DHCP client-id state (.127/.128). Do not force a lease here.
/ip dns set servers=1.1.1.1,8.8.8.8 allow-remote-requests=yes cache-size=4096KiB
:if ([:len [/ip dns static find where name="router.zeaz.internal"]] = 0) do={ /ip dns static add name=router.zeaz.internal address=192.168.1.1 type=A comment="OMEGA-MANAGED" }
:if ([:len [/ip dns static find where name="core.zeaz.internal"]] = 0) do={ /ip dns static add name=core.zeaz.internal address=192.168.1.128 type=A comment="OMEGA-MANAGED" }
/system clock set time-zone-name=Asia/Bangkok
/system ntp client set enabled=yes
:put "DHCP DNS NTP PASS"
:log warning "OMEGA DHCP DNS NTP PASS"
