# CORE SSH Hardening

## Production baseline

`core/install.sh` enforces:

~~~text
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
KbdInteractiveAuthentication no
UsePAM yes
~~~

Password authentication is disabled by default. The installer refuses to switch to key-only mode when the selected user's `authorized_keys` file is missing or empty.

## Provision a public key

Generate/locate the key on the client workstation. Copy only the `.pub` content to the server. Never copy or paste the private key into chat, Git, shell history, or `authorized_keys`.

On CORE:

~~~bash
install -d -m 700 ~/.ssh
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
~~~

Append the complete `ssh-ed25519 ...` public-key line to `authorized_keys` and keep ownership on the target account.

## Verify before closing recovery access

From another host, test key-only authentication explicitly:

~~~text
ssh -i <private-key-path> -o IdentitiesOnly=yes -o PasswordAuthentication=no <user>@<core-ip>
~~~

On CORE, verify effective sshd settings:

~~~bash
sudo sshd -t
sudo sshd -T | grep -E '^(permitrootlogin|pubkeyauthentication|passwordauthentication|authorizedkeysfile)'
systemctl is-active ssh
ss -ltnp | grep ':22'
~~~

Expected production result includes `permitrootlogin no`, `pubkeyauthentication yes`, and `passwordauthentication no`.

## Emergency password bootstrap

Only when no key exists and a recovery path is required:

~~~bash
sudo SSH_ALLOW_PASSWORD=yes ./core/install.sh
~~~

Install/prove a key immediately, then rerun with `SSH_ALLOW_PASSWORD=no`.

## Client host-key verification

First connection to a new IP/name can require host-key confirmation. When possible, compare the displayed fingerprint with the server's `/etc/ssh/ssh_host_ed25519_key.pub` fingerprint over an already-trusted channel before accepting it.
