:log warning "OMEGA DHCP DNS NTP START"

# zOS owns only resources explicitly named/commented below. Existing resources
# are never deleted or rewritten merely because they differ from the desired
# topology. A conflicting live object fails the phase instead of being taken over.
:if ([:len [/ip pool find where name="client-dhcp-pool"]] = 0) do={
    /ip pool add name=client-dhcp-pool ranges=192.168.1.50-192.168.1.199 comment="OMEGA-MANAGED"
} else={
    :local poolId [/ip pool find where name="client-dhcp-pool"]
    :if ([/ip pool get $poolId ranges] != "192.168.1.50-192.168.1.199") do={
        :error "client-dhcp-pool exists with non-zOS ranges; refusing takeover"
    }
}

:if ([:len [/ip dhcp-server find where name="dhcp-client"]] = 0) do={
    /ip dhcp-server add name=dhcp-client interface=bridge-lan address-pool=client-dhcp-pool lease-time=12h disabled=no comment="OMEGA-MANAGED"
} else={
    :local dhcpId [/ip dhcp-server find where name="dhcp-client"]
    :if ([/ip dhcp-server get $dhcpId comment] != "OMEGA-MANAGED") do={
        :error "dhcp-client exists but is not zOS-owned; refusing takeover"
    }
    :if ([/ip dhcp-server get $dhcpId interface] != "bridge-lan" || [/ip dhcp-server get $dhcpId address-pool] != "client-dhcp-pool") do={
        :error "zOS-owned dhcp-client differs from contract; refusing implicit rewrite"
    }
}

:if ([:len [/ip dhcp-server network find where address="192.168.1.0/24" and comment="OMEGA-MANAGED"]] = 0) do={
    :if ([:len [/ip dhcp-server network find where address="192.168.1.0/24"]] = 0) do={
        /ip dhcp-server network add address=192.168.1.0/24 gateway=192.168.1.1 dns-server=192.168.1.1 comment="OMEGA-MANAGED"
    } else={
        :error "192.168.1.0/24 DHCP network exists without zOS ownership; refusing takeover"
    }
}

# Do not delete ether2 DHCP servers or 0.0.0.0/24 networks: their ownership is
# not established by this phase. Do not overwrite global DNS resolver state.
# CORE LAN is runtime/DHCP evidence; DEV_LAN_IP is intentionally unset.
:if ([:len [/ip dns static find where name="router.zeaz.internal"]] = 0) do={
    /ip dns static add name=router.zeaz.internal address=192.168.1.1 type=A comment="OMEGA-MANAGED"
} else={
    :local routerDnsId [/ip dns static find where name="router.zeaz.internal"]
    :if ([/ip dns static get $routerDnsId address] != "192.168.1.1") do={
        :error "router.zeaz.internal exists with a different address; refusing takeover"
    }
}

# Never invent a CORE LAN address. A core.zeaz.internal record is added only by
# a separate evidence-driven workflow once DEV_LAN_IP has been observed.
/system clock set time-zone-name=Asia/Bangkok
/system ntp client set enabled=yes
:put "DHCP DNS NTP PASS"
:log warning "OMEGA DHCP DNS NTP PASS"
