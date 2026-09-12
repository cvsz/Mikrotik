# Imported RouterOS Skills

The files under `skills/routeros-*/` are vendored from the public `tikoci/routeros-skills` project so zOS agents and validation workflows can use RouterOS-specific operational knowledge alongside the zOS control plane.

- Upstream: https://github.com/tikoci/routeros-skills
- Upstream owner: `tikoci`
- Default source branch: `main`
- License: MIT; see `THIRD_PARTY_NOTICES.md`

## Imported skill set

- routeros-app-yaml
- routeros-capsman
- routeros-command-tree
- routeros-container
- routeros-firewall
- routeros-fundamentals
- routeros-hotspot
- routeros-mac-telnet
- routeros-mndp
- routeros-netinstall
- routeros-qemu-chr
- routeros-quickchr
- routeros-scripting
- routeros-sniffer
- routeros-syntax-inspection

## Proposed-upstream additions vendored ahead of merge

Two useful upstream pull requests are intentionally vendored before they merge upstream:

- `routeros-capsman` from upstream PR #19. The zOS copy is sanitized to replace deployment-specific AP names and MAC addresses with neutral placeholders before import.
- `routeros-fundamentals/references/rest-api-patterns.md` guidance from upstream PR #20 at commit `74bd78b39c84507b9126e8526583d578bb0598d0`. It documents the verified synchronous `/rest/execute` case where RouterOS can return HTTP 200 while the command itself is rejected, so automation must not treat HTTP status alone as proof of success.

These two files should be reconciled with upstream once PR #19/#20 merge or materially change. Do not silently overwrite the zOS safety edits during a future sync.

## Reference integrity

Several upstream skills link to companion files under `references/`. zOS now keeps those relative link targets present in the vendored tree. Where the full reference has not yet been synchronized, the local file is an explicit provenance pointer to the canonical upstream document rather than a dead link.

CI validates relative Markdown `.md` links under `skills/` and fails if a referenced local file is missing.

## zOS safety adaptations

The vendored skills are not copied blindly. zOS applies safety corrections where generic examples could be dangerous in this production context, including:

- fictional documentation networks instead of the real PoliceDBC LAN gateway in generic RouterOS examples;
- explicit lab/disposable-only gating for Netinstall empty-configuration (`-e`) examples;
- no production credentials, private keys, or site-specific identifiers;
- stable selectors or looked-up IDs instead of fragile hard-coded internal IDs where practical.

## Safety rules

- Never import real credentials, private keys, site-specific secrets, or production identifiers.
- Prefer stable RouterOS selectors (`name=`, `comment=`, looked-up `.id`) over hard-coded internal IDs.
- Imported knowledge does not bypass zOS production gates: live changes still require backup, dry-run, RouterOS Safe Mode/recovery access where appropriate, explicit operator opt-in, and post-change verification.
