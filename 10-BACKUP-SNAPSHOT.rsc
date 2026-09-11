:log warning "OMEGA BACKUP START"
/export terse file=omega-policedbc-before
/system backup save name=omega-policedbc-before dont-encrypt=yes
:put "BACKUP PASS: omega-policedbc-before.rsc and .backup"
:log warning "OMEGA BACKUP PASS"
