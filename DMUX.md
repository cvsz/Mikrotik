# dmux Instructions for zOS

Every pane/agent must follow `AGENTS.md`.

Use isolated branches/worktrees for concurrent tasks, avoid parallel edits to the same file without coordination, and never resolve conflicts by weakening CI, secret scanning, or production gates.

Before integration:

~~~bash
make validate
make docs
make evidence
~~~

`docs/INDEX.md` defines shared documentation ownership; `docs/GITHUB-OPERATIONS.md` defines PR/merge expectations.
