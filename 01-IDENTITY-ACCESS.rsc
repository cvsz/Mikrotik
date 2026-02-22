:log warning "PHASE 01 IDENTITY"
/system identity set name=zeaz-gateway
/user set admin password=CHANGE_ME_STRONG_PASSWORD
/ip service
set telnet disabled=yes
set ftp disabled=yes
set www disabled=yes
set api disabled=yes
set api-ssl disabled=yes
set ssh disabled=yes
set winbox disabled=yes
:log warning "PHASE 01 DONE"
