#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from pathlib import Path
from urllib.parse import unquote

ROOT = Path(__file__).resolve().parents[1]

REQUIRED = [
    'README.md', 'AGENTS.md', 'CHANGELOG.md', 'CHECKLIST.md', 'CONTRIBUTING.md',
    'SECURITY.md', 'CODE_OF_CONDUCT.md', 'GOVERNANCE.md', 'MAINTAINERS.md', 'SUPPORT.md',
    'ENVIRONMENTS.md', 'THIRD_PARTY_NOTICES.md',
    'docs/INDEX.md', 'docs/ARCHITECTURE.md', 'docs/INSTALLATION.md', 'docs/RUNBOOK.md',
    'docs/NETWORK-RECOVERY.md', 'docs/SSH-HARDENING.md', 'docs/DISASTER-RECOVERY.md',
    'docs/PRODUCTION-READINESS.md', 'docs/PRODUCTION-MIGRATION.md',
    'docs/GITHUB-OPERATIONS.md', 'docs/GITHUB-SETTINGS.md', 'docs/TESTING.md',
    'docs/RELEASES.md', 'docs/ROADMAP.md', 'docs/LICENSING.md',
    '.github/PULL_REQUEST_TEMPLATE.md', '.github/CODEOWNERS',
]

LINK_RE = re.compile(r'(?<!!)\[[^\]]+\]\(([^)]+)\)')

def project_markdown() -> list[Path]:
    docs = []
    for path in ROOT.rglob('*.md'):
        rel = path.relative_to(ROOT).as_posix()
        if rel.startswith('.git/'):
            continue
        if rel.startswith('skills/routeros-'):
            continue
        docs.append(path)
    return sorted(docs)

def local_target(source: Path, raw: str) -> Path | None:
    target = raw.strip()
    if not target or target.startswith(('#', 'http://', 'https://', 'mailto:')):
        return None
    if ' ' in target and not target.startswith('<'):
        target = target.split(' ', 1)[0]
    target = target.strip('<>')
    target = target.split('#', 1)[0].split('?', 1)[0]
    if not target:
        return None
    target = unquote(target)
    if target.startswith('/'):
        return ROOT / target.lstrip('/')
    return (source.parent / target).resolve()

def main() -> int:
    errors: list[str] = []
    for rel in REQUIRED:
        if not (ROOT / rel).exists():
            errors.append(f'missing required documentation/community file: {rel}')

    for path in project_markdown():
        rel = path.relative_to(ROOT).as_posix()
        text = path.read_text(encoding='utf-8')
        if 'cvsz/Mikrotik' in text or 'github.com/cvsz/Mikrotik' in text:
            errors.append(f'stale repository name in {rel}: expected cvsz/zos')
        for match in LINK_RE.finditer(text):
            target = local_target(path, match.group(1))
            if target is None:
                continue
            try:
                target.relative_to(ROOT)
            except ValueError:
                errors.append(f'local Markdown link escapes repository in {rel}: {match.group(1)}')
                continue
            if not target.exists():
                errors.append(f'broken local Markdown link in {rel}: {match.group(1)}')

    if errors:
        for error in errors:
            print(f'ERROR: {error}', file=sys.stderr)
        return 1

    print(f'Documentation validation PASS ({len(project_markdown())} project Markdown files checked)')
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
