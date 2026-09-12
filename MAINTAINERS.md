# Maintainers

## Current maintainer

- GitHub owner/maintainer: `@cvsz`

## Responsibilities

The maintainer is responsible for repository policy, branch/ruleset configuration, release approval, security response, self-hosted runner trust, production-safety exceptions, and final merge decisions.

## Review expectations

For production-sensitive changes, review should verify:

- recovery access remains available;
- topology assumptions are current;
- secrets are not introduced;
- live mutation remains explicitly gated;
- validation/evidence is appropriate for the change;
- documentation and rollback implications are synchronized.

## Bus-factor note

The project currently has a single declared maintainer. If additional maintainers are added, update this file, `CODEOWNERS`, GitHub rulesets, runner access, package permissions, and incident-response contacts together.
