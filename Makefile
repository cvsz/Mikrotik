SHELL := /usr/bin/env bash

.PHONY: validate status audit backup dry-run apply verify e2e core-status core-check core-repair core-find-conflict zos zos-doctor zos-install update-check update-notify update-auto update-monitor-install

validate:
	./tools/validate-repo.sh

status:
	./tools/omega-router.sh status

audit:
	./tools/omega-router.sh audit

backup:
	./tools/omega-router.sh backup

dry-run:
	./tools/deploy-phases.sh dry-run

apply:
	@echo "Apply requires RouterOS Safe Mode and OMEGA_ALLOW_LIVE_APPLY=1"
	./tools/deploy-phases.sh apply

verify:
	./tools/deploy-phases.sh verify

e2e:
	./tools/e2e-check.sh

core-status:
	./tools/core-network-repair.sh status

core-check:
	./tools/core-network-repair.sh check

core-repair:
	./tools/core-network-repair.sh repair-runtime

core-find-conflict:
	./tools/core-network-repair.sh find-conflict

zos:
	./zOS/bin/zos help

zos-doctor:
	./zOS/bin/zos doctor

zos-install:
	./zOS/install.sh

update-check:
	./tools/routeros-auto-update.sh check

update-notify:
	./tools/routeros-auto-update.sh notify

update-auto:
	@echo "Automatic RouterOS install requires OMEGA_AUTO_ROUTEROS_UPDATE=1 and OMEGA_ALLOW_ROUTER_REBOOT=1"
	./tools/routeros-auto-update.sh check-and-update

update-monitor-install:
	./tools/install-update-monitor.sh
