:log warning "OMEGA DHCP DNS NTP START"

# zOS owns only the verified LAN DHCP/DNS contract below. Conflicting live
# objects are preserved and cause this phase to fail rather than being rewritten.
:local desiredRanges "192.168.1.50-192.168.1.99,192.168.1.101-192.168.1.118,192.168.1.121,192.168.1.124-192.168.1.199"
:if ([:len [/ip pool find where name="lan-pool"]] = 0) do={
    /ip pool add name=lan-pool ranges=$desiredRanges comment="OMEGA-MANAGED"
} else={
    :local poolId [/ip pool find where name="lan-pool"]
    :if ([/ip pool get $poolId ranges] != $desiredRanges) do={
        :error "lan-pool exists with ranges outside the verified contract; refusing takeover"
    }
}

:if ([:len [/ip dhcp-server find where name="lan-dhcp"]] = 0) do={
    /ip dhcp-server add name=lan-dhcp interface=bridgeLocal address-pool=lan-pool lease-time=12h authoritative=yes disabled=no comment="OMEGA-MANAGED LAN DHCP"
} else={
    :local dhcpId [/ip dhcp-server find where name="lan-dhcp"]
    :if ([/ip dhcp-server get $dhcpId interface] != "bridgeLocal") do={ :error "lan-dhcp exists on another interface; refusing takeover" }
    :if ([/ip dhcp-server get $dhcpId address-pool] != "lan-pool") do={ :error "lan-dhcp uses another pool; refusing takeover" }
    :if ([/ip dhcp-server get $dhcpId disabled] = true) do={ :error "lan-dhcp exists but is disabled; refusing implicit enable" }
}

:if ([:len [/ip dhcp-server network find where address="192.168.1.0/24"]] = 0) do={
    /ip dhcp-server network add address=192.168.1.0/24 gateway=192.168.1.1 dns-server=192.168.1.1 comment="OMEGA-MANAGED"
} else={
    :local netId [/ip dhcp-server network find where address="192.168.1.0/24"]
    :if ([/ip dhcp-server network get $netId gateway] != "192.168.1.1") do={ :error "LAN DHCP gateway differs from contract; refusing takeover" }
    :if ([/ip dhcp-server network get $netId dns-server] != "192.168.1.1") do={ :error "LAN DHCP DNS differs from contract; refusing takeover" }
}

# Do not delete ether2 DHCP servers, unrelated DHCP networks, or overwrite
# global upstream DNS servers. Only the verified fixed leases below are owned.

:local leaseId [/ip dhcp-server lease find where mac-address="48:4D:7E:D4:3A:C6"]
:if ([:len $leaseId] = 0) do={
    :if ([:len [/ip dhcp-server lease find where address="192.168.1.100"]] > 0) do={ :error "192.168.1.100 is occupied by another lease" }
    /ip dhcp-server lease add server=lan-dhcp address=192.168.1.100 mac-address=48:4D:7E:D4:3A:C6 comment="PoliceDBC-SEA"
} else={
    :if ([/ip dhcp-server lease get $leaseId address] != "192.168.1.100") do={ :error "PoliceDBC-SEA MAC has a different lease; refusing rewrite" }
    /ip dhcp-server lease make-static $leaseId
    /ip dhcp-server lease set $leaseId server=lan-dhcp comment="PoliceDBC-SEA"
}

:set leaseId [/ip dhcp-server lease find where mac-address="00:0C:29:B7:22:AF"]
:if ([:len $leaseId] = 0) do={
    :if ([:len [/ip dhcp-server lease find where address="192.168.1.119"]] > 0) do={ :error "192.168.1.119 is occupied by another lease" }
    /ip dhcp-server lease add server=lan-dhcp address=192.168.1.119 mac-address=00:0C:29:B7:22:AF comment="ha-a.zeaz.dev"
} else={
    :if ([/ip dhcp-server lease get $leaseId address] != "192.168.1.119") do={ :error "ha-a MAC has a different lease; refusing rewrite" }
    /ip dhcp-server lease make-static $leaseId
    /ip dhcp-server lease set $leaseId server=lan-dhcp comment="ha-a.zeaz.dev"
}

:set leaseId [/ip dhcp-server lease find where mac-address="00:0C:29:72:EF:42"]
:if ([:len $leaseId] = 0) do={
    :if ([:len [/ip dhcp-server lease find where address="192.168.1.120"]] > 0) do={ :error "192.168.1.120 is occupied by another lease" }
    /ip dhcp-server lease add server=lan-dhcp address=192.168.1.120 mac-address=00:0C:29:72:EF:42 comment="ha-b.zeaz.dev"
} else={
    :if ([/ip dhcp-server lease get $leaseId address] != "192.168.1.120") do={ :error "ha-b MAC has a different lease; refusing rewrite" }
    /ip dhcp-server lease make-static $leaseId
    /ip dhcp-server lease set $leaseId server=lan-dhcp comment="ha-b.zeaz.dev"
}

:set leaseId [/ip dhcp-server lease find where mac-address="00:0C:29:B5:F4:09"]
:if ([:len $leaseId] = 0) do={
    :if ([:len [/ip dhcp-server lease find where address="192.168.1.122"]] > 0) do={ :error "192.168.1.122 is occupied by another lease" }
    /ip dhcp-server lease add server=lan-dhcp address=192.168.1.122 mac-address=00:0C:29:B5:F4:09 comment="prod.zeaz.dev"
} else={
    :if ([/ip dhcp-server lease get $leaseId address] != "192.168.1.122") do={ :error "prod MAC has a different lease; refusing rewrite" }
    /ip dhcp-server lease make-static $leaseId
    /ip dhcp-server lease set $leaseId server=lan-dhcp comment="prod.zeaz.dev"
}

/ip dns set allow-remote-requests=yes

:local dnsId [/ip dns static find where name="prod.zeaz.dev"]
:if ([:len $dnsId] = 0) do={ /ip dns static add name=prod.zeaz.dev address=192.168.1.122 ttl=1d comment="OMEGA-MANAGED zeaz prod" } else={ :if ([/ip dns static get $dnsId address] != "192.168.1.122") do={ :error "prod.zeaz.dev DNS conflicts with verified address" } }
:set dnsId [/ip dns static find where name="core.zeaz.dev"]
:if ([:len $dnsId] = 0) do={ /ip dns static add name=core.zeaz.dev address=192.168.1.123 ttl=1d comment="OMEGA-MANAGED zeaz core" } else={ :if ([/ip dns static get $dnsId address] != "192.168.1.123") do={ :error "core.zeaz.dev DNS conflicts with reserved address" } }
:set dnsId [/ip dns static find where name="ha-a.zeaz.dev"]
:if ([:len $dnsId] = 0) do={ /ip dns static add name=ha-a.zeaz.dev address=192.168.1.119 ttl=1d comment="OMEGA-MANAGED zeaz ha-a" } else={ :if ([/ip dns static get $dnsId address] != "192.168.1.119") do={ :error "ha-a.zeaz.dev DNS conflicts with verified address" } }
:set dnsId [/ip dns static find where name="ha-b.zeaz.dev"]
:if ([:len $dnsId] = 0) do={ /ip dns static add name=ha-b.zeaz.dev address=192.168.1.120 ttl=1d comment="OMEGA-MANAGED zeaz ha-b" } else={ :if ([/ip dns static get $dnsId address] != "192.168.1.120") do={ :error "ha-b.zeaz.dev DNS conflicts with verified address" } }

/system clock set time-zone-name=Asia/Bangkok
/system ntp client set enabled=yes
:put "DHCP DNS NTP PASS"
:log warning "OMEGA DHCP DNS NTP PASS"
