# Recommended GitHub Settings

Repository: `cvsz/zos`.

These are recommended administrative settings. They are not claims about account-plan features that have not been verified in the UI.

## General

- default branch: `main`;
- squash merge: enabled/preferred for focused PRs;
- automatic deletion of merged head branches: enabled;
- Issues: enabled;
- Discussions: optional;
- Wiki: disabled or unused; canonical documentation lives in-repo.

## Main branch ruleset

Recommended:

- require pull request before merge;
- require conversation resolution;
- require status checks from repository validation/build workflows;
- require branch to be up to date where practical;
- block force pushes and branch deletion;
- require approvals when additional maintainers/reviewers exist;
- optionally require signed commits/tags if an organization-wide signing policy is adopted.

When configuring required checks, select the exact check contexts GitHub presents after a successful workflow run rather than guessing names from YAML filenames.

## Actions permissions

- default workflow token permissions: read repository contents;
- package write is granted only to `zos-build.yml` where required;
- ordinary workflows do not receive production router credentials;
- untrusted fork code must not run on the privileged self-hosted runner;
- third-party Actions should be pinned/reviewed according to the repository dependency policy when one is adopted.

## Security features

Enable where supported:

- Dependabot alerts/security updates;
- secret scanning and push protection;
- private vulnerability reporting;
- CodeQL/default setup for supported languages;
- rules preventing accidental exposure of Actions secrets to untrusted events.

## Packages

Current controller image path:

~~~text
ghcr.io/cvsz/mikrotik-zos
~~~

Package visibility is an owner decision. A public GitHub repository does not require the package to be public.

## Pages

No GitHub Pages publication workflow is currently part of the documented production path. Do not claim a Pages site is deployed until a reviewed workflow/site exists.

## Self-hosted runner

Keep `zOS-Runner` restricted to trusted repository workloads and a single listener session. See `docs/SELF_HOSTED_RUNNER.md`.

Cloudflare credentials must be stored as protected host/runtime secrets, never repository files or ordinary CI variables. Cloudflare deployment workflows are not enabled by this repository documentation and require separate review.

## Community health

Keep `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `SECURITY.md`, `SUPPORT.md`, `GOVERNANCE.md`, `MAINTAINERS.md`, issue templates, pull-request template, and CODEOWNERS current.
