:log warning "OMEGA PRECHECK START"
:put "===== OMEGA PRECHECK ====="
/system resource print
/system package print
/system identity print
:if ([:len [/interface find where name="ether1"]] = 0) do={ :error "PRECHECK FAIL: ether1 missing" }
:if ([:len [/interface bridge find where name="bridge-lan"]] = 0) do={ :error "PRECHECK FAIL: bridge-lan missing" }
:if ([:len [/interface wireguard find where name="wg-remote"]] = 0) do={ :error "PRECHECK FAIL: wg-remote missing" }
:if ([:len [/ip address find where address="192.168.205.251/21" and interface="ether1"]] = 0) do={ :error "PRECHECK FAIL: expected WAN missing" }
:if ([:len [/ip address find where address="192.168.1.1/24" and interface="bridge-lan"]] = 0) do={ :error "PRECHECK FAIL: expected LAN gateway missing" }
:if ([:len [/ip route find where dst-address="0.0.0.0/0" and gateway="192.168.200.1"]] = 0) do={ :error "PRECHECK FAIL: expected default route missing" }
:put "PRECHECK PASS"
:log warning "OMEGA PRECHECK PASS"
