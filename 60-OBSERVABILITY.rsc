:log warning "OMEGA OBSERVABILITY START"

# Keep production logging local by default. Remote syslog requires an explicitly
# verified destination and is intentionally not invented here.
:if ([:len [/system logging find where topics="firewall" and action="memory"]] = 0) do={
    /system logging add topics=firewall action=memory comment="OMEGA-MANAGED"
}
:if ([:len [/system logging find where topics="wireguard" and action="memory"]] = 0) do={
    /system logging add topics=wireguard action=memory comment="OMEGA-MANAGED"
}
:if ([:len [/system logging find where topics="critical" and action="memory"]] = 0) do={
    /system logging add topics=critical action=memory comment="OMEGA-MANAGED"
}

:put "OBSERVABILITY PASS"
:log warning "OMEGA OBSERVABILITY PASS"
