# OpenCode Instructions for zOS

Use `AGENTS.md` as the canonical operating contract.

Resolve repository state before editing, preserve production fail-closed behavior, do not invent topology or credentials, and keep behavior/evidence/documentation changes together.

Use `docs/INDEX.md` for documentation ownership and `docs/TESTING.md` for the validation matrix.

~~~bash
make validate
make docs
make evidence
~~~
