# Imported RouterOS Skills

`skills/routeros-*/` contains vendored RouterOS operational knowledge from `tikoci/routeros-skills` for agent grounding and validation.

- upstream: `https://github.com/tikoci/routeros-skills`;
- source branch: `main` unless a documented PR/commit is intentionally vendored;
- license/provenance: `THIRD_PARTY_NOTICES.md`.

## Documentation ownership boundary

These skill Markdown files are upstream-derived. They are intentionally excluded from blanket project-document rewriting. Preserve upstream semantics/provenance and make only deliberate sync or zOS safety adaptations.

`skills/README.md` is project-owned and documents the integration boundary.

## Imported set

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

## Ahead-of-upstream adaptations

Where useful upstream PR content is vendored before merge, record the source PR/commit and preserve any zOS safety sanitization. Do not silently overwrite local safety adaptations during sync.

## Validation

The RouterOS skills workflow verifies required skill structure, relative Markdown references, and high-confidence secret patterns independently of project-owned `make docs` validation.

## Production safety

Imported knowledge does not bypass zOS production gates. Live work still requires audit, backup, dry-run, recovery/Safe Mode where appropriate, explicit operator opt-in, and independent verification.
