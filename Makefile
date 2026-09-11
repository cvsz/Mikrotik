SHELL := /usr/bin/env bash

.PHONY: validate status audit backup dry-run apply verify core-status core-check core-repair core-find-conflict

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

core-status:
	./tools/core-network-repair.sh status

core-check:
	./tools/core-network-repair.sh check

core-repair:
	./tools/core-network-repair.sh repair-runtime

core-find-conflict:
	./tools/core-network-repair.sh find-conflict
