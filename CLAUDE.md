# Claude Instructions for zOS

`AGENTS.md` is the canonical repository and production-safety contract.

- inspect current files and runtime evidence before proposing changes;
- keep RouterOS mutation operator-gated;
- do not invent PROD addresses or successful live results;
- preserve SSH key-only and APT signature-verification controls;
- do not use CI to bypass recovery or review requirements;
- keep project documentation synchronized through `docs/INDEX.md`.

Before finishing a repository change:

~~~bash
make validate
make docs
make evidence
~~~

Use `docs/GITHUB-OPERATIONS.md` for runner/CI/package conventions and `docs/PRODUCTION-READINESS.md` for acceptance language.
