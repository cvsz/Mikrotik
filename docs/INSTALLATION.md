# Installation

## Supported control-plane model

zOS is installed on a Linux controller/DEV host. RouterOS remains on the MikroTik router. The repository also contains a separate Windows self-hosted GitHub Actions runner procedure.

## Controller checkout

~~~bash
git clone https://github.com/cvsz/zos.git
cd zos
cp config/topology.env.example config/topology.env
chmod 600 config/topology.env
~~~

Review the topology file before using it. Empty/unknown addresses must remain empty until verified.

## Environment templates

The repository includes four example surfaces:

| Template | Purpose |
|---|---|
| `.env.example` | optional shell/IDE/operator overrides |
| `config/topology.env.example` | canonical topology and zOS safety/update policy |
| `core/.env.example` | `core/install.sh` recovery/bootstrap options |
| `zOS/.env.example` | zOS runtime/update-policy options |

Only `config/topology.env` is the normal topology runtime file. The other `.env` templates are not auto-loaded; source/export them explicitly only when needed.

Example for CORE overrides:

~~~bash
cp core/.env.example core/.env
# edit core/.env, then:
set -a
source core/.env
set +a
sudo --preserve-env=LAN_IFACE,WG_IFACE,LAN_CIDR,GW,SSH_PORT,SSH_ALLOW_PASSWORD,SSH_USER ./core/install.sh
~~~

Real `.env` files are ignored by Git. Never place passwords, access tokens, SSH/WireGuard private keys, or populated production secrets in an example file.

## Install controller tooling

~~~bash
./tools/install-controller.sh
./zOS/bin/zos doctor
make validate
make docs
~~~

Operational entry points are tracked executable in Git. Do not normalize away an unexpected permission-mode defect with permanent installation-time `chmod` workarounds.

## CORE SSH/network bootstrap

If the existing CORE host needs recovery:

~~~bash
cd /home/<repo-owner>/zos
git pull --ff-only origin main
sudo ./core/install.sh
~~~

The secure default requires a preinstalled public key for the selected SSH user. See `core/README.md` and `docs/SSH-HARDENING.md`.

## Router credentials

zOS must not store a router password/private key in the repository. Use the controller key/bootstrap flow and a verified RouterOS management account.

## Self-hosted runner

Windows runner installation/registration is separate from controller installation. See `docs/SELF_HOSTED_RUNNER.md`. The runner is for trusted validation workloads, not implicit production apply.

## Verify installation

~~~bash
./zOS/bin/zos help
./zOS/bin/zos doctor
make validate
make docs
make evidence
~~~

Then perform runtime checks only when the live network is intentionally in scope.
