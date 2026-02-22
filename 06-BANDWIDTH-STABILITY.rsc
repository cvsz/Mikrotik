:log warning "PHASE 06 BANDWIDTH"
/queue simple add name=GLOBAL target=bridge-lan max-limit=950M/475M queue=fq-codel/fq-codel
:log warning "PHASE 06 DONE"
