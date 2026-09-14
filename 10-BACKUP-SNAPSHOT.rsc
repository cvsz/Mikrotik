:log warning "OMEGA BACKUP SNAPSHOT START"
# Backup creation is performed by tools/omega-router.sh before phase imports.
# This phase is intentionally a marker only so apply does not create a second
# router-local binary snapshot.
:put "BACKUP SNAPSHOT PASS: controller backup completed before import phases"
:log warning "OMEGA BACKUP SNAPSHOT PASS"
