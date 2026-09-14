:log warning "OMEGA DHCP DNS NTP START"
:if ([:len [/ip pool find where name="lan-pool"]] = 0) do={
    /ip pool add name=lan-pool ranges=192.168.1.50-192.168.1.99,192.168.1.101-192.168.1.118,192.168.1.121,192.168.1.124-192.168.1.199
} else={
    /ip pool set [find where name="lan-pool"] ranges=192.168.1.50-192.168.1.99,192.168.1.101-192.168.1.118,192.168.1.121,192.168.1.124-192.168.1.199
}
:if ([:len [/ip dhcp-server find where name="lan-dhcp"]] = 0) do={
    /ip dhcp-server add name=lan-dhcp interface=bridgeLocal address-pool=lan-pool lease-time=12h authoritative=yes disabled=no comment="OMEGA-MANAGED LAN DHCP"
} else={
    /ip dhcp-server set [find where name="lan-dhcp"] interface=bridgeLocal address-pool=lan-pool lease-time=12h authoritative=yes disabled=no
}
:if ([:len [/ip dhcp-server network find where address="192.168.1.0/24"]] = 0) do={
    /ip dhcp-server network add address=192.168.1.0/24 gateway=192.168.1.1 dns-server=192.168.1.1 comment="OMEGA-MANAGED"
} else={
    /ip dhcp-server network set [find where address="192.168.1.0/24"] gateway=192.168.1.1 dns-server=192.168.1.1
}
:if ([:len [/ip dhcp-server lease find where mac-address="48:4D:7E:D4:3A:C6"]] = 0) do={ /ip dhcp-server lease add server=lan-dhcp address=192.168.1.100 mac-address=48:4D:7E:D4:3A:C6 comment="PoliceDBC-SEA" }
:if ([:len [/ip dhcp-server lease find where mac-address="00:0C:29:B7:22:AF"]] = 0) do={ /ip dhcp-server lease add server=lan-dhcp address=192.168.1.119 mac-address=00:0C:29:B7:22:AF comment="ha-a.zeaz.dev" }
:if ([:len [/ip dhcp-server lease find where mac-address="00:0C:29:72:EF:42"]] = 0) do={ /ip dhcp-server lease add server=lan-dhcp address=192.168.1.120 mac-address=00:0C:29:72:EF:42 comment="ha-b.zeaz.dev" }
:if ([:len [/ip dhcp-server lease find where mac-address="00:0C:29:B5:F4:09"]] = 0) do={ /ip dhcp-server lease add server=lan-dhcp address=192.168.1.122 mac-address=00:0C:29:B5:F4:09 comment="prod.zeaz.dev" }
/ip dns set allow-remote-requests=yes
:if ([:len [/ip dns static find where name="prod.zeaz.dev"]] = 0) do={ /ip dns static add name=prod.zeaz.dev address=192.168.1.122 ttl=1d comment="OMEGA-MANAGED zeaz prod" }
:if ([:len [/ip dns static find where name="core.zeaz.dev"]] = 0) do={ /ip dns static add name=core.zeaz.dev address=192.168.1.123 ttl=1d comment="OMEGA-MANAGED zeaz core" }
:if ([:len [/ip dns static find where name="ha-a.zeaz.dev"]] = 0) do={ /ip dns static add name=ha-a.zeaz.dev address=192.168.1.119 ttl=1d comment="OMEGA-MANAGED zeaz ha-a" }
:if ([:len [/ip dns static find where name="ha-b.zeaz.dev"]] = 0) do={ /ip dns static add name=ha-b.zeaz.dev address=192.168.1.120 ttl=1d comment="OMEGA-MANAGED zeaz ha-b" }
/system clock set time-zone-name=Asia/Bangkok
/system ntp client set enabled=yes
:put "DHCP DNS NTP PASS"
:log warning "OMEGA DHCP DNS NTP PASS"
