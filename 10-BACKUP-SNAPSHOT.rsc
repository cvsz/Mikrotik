:log warning "OMEGA BACKUP SNAPSHOT START"
# Binary/text backup is owned by tools/omega-router.sh backup, which creates an
# AES-SHA256 encrypted binary backup, downloads it, and removes router-side
# temporary files. Keeping backup creation out of this import phase prevents an
# unencrypted backup from being created during live apply.
:put "BACKUP SNAPSHOT PASS: controller-managed encrypted backup required"
:log warning "OMEGA BACKUP SNAPSHOT PASS"
