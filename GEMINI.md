# Gemini Instructions for zOS

Follow `AGENTS.md` as the canonical policy.

Ground recommendations in current repository/runtime evidence, keep DEV/PROD identity and topology distinctions explicit, preserve backup/dry-run/recovery/live-apply gates, and never place real secrets or private operational evidence in generated files.

Project documentation is indexed by `docs/INDEX.md`; vendored skill Markdown retains upstream provenance.

Validation baseline:

~~~bash
make validate
make docs
make evidence
~~~
