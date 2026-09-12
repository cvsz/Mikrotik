# Recommended GitHub Settings

Apply these repository settings for `cvsz/Mikrotik` where supported by the account/plan.

## General
- Default branch: `main`
- Allow squash merge: enabled
- Allow rebase merge: enabled
- Delete head branches automatically: enabled
- Issues: enabled
- Projects: optional
- Wiki: disabled; keep documentation in repo

## Branch protection / ruleset for `main`
- Require pull request before merging
- Require at least one approval when collaborating with others
- Dismiss stale approvals on new commits
- Require status checks: `validate-routeros-stack`, `build-zos`
- Require branch to be up to date before merge
- Block force pushes
- Block branch deletion
- Require conversation resolution

## Actions
- Default workflow permissions: read repository contents
- Allow explicit package write only in the zOS build workflow
- Do not place production router credentials in workflow secrets unless a future deployment design explicitly requires it
- Live router deployment from GitHub-hosted runners is intentionally unsupported

## Pages
Use GitHub Actions as the Pages source. The Pages workflow publishes the static documentation portal only; it does not expose topology secrets.

## Packages
The `build-zos` workflow publishes the controller-side OCI package to:

`ghcr.io/cvsz/mikrotik-zos`

Keep the package private unless public distribution is intentionally approved.

## Security
- Enable Dependabot alerts and security updates
- Enable secret scanning where available
- Enable push protection where available
- Enable private vulnerability reporting where available
- Enable CodeQL/default setup if supported for the repository languages
