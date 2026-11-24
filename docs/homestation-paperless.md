# Paperless-ngx on homestation

Paperless-ngx is the household document archive at `https://docs.npham.de`.
The app stores documents in PostgreSQL and its `media` directory. OCR is local
and configured for German, English, and Vietnamese; German is the search
language. Vietnamese is installed as an extra OCR language at container start,
so mixed-language OCR uses more CPU than a single-language setup.

LLM features are explicitly disabled. Paperless's built-in classifier remains
available; it runs locally and does not send documents to a cloud model. See
the [Paperless AI documentation](https://docs.paperless-ngx.com/advanced_usage/).

Outgoing mail (password reset, workflow notifications) uses the shared
`homelab.smtp` settings, like the other homestation apps.

## Rollout switches

[`paperless.nix`](../configurations/nixos/homestation/homelab/paperless.nix)
has two switches at the top. Each one needs keys in
`secrets/hosts/homestation/paperless.yaml` before it is set to `true`;
`sops.nix` only declares those keys while the switch is on.

| Switch | Needs keys | Effect |
|--------|------------|--------|
| `sso` | `oidc-client-id`, `oidc-client-secret` | Pocket ID login; ingress switches from private to public |
| `ssoOnly` | none (needs `sso`) | Hides password login and redirects to Pocket ID; keep `false` while the local account is needed |
| `mailIntake` | `bridge-certificate` | Proton Bridge IMAP relay, certificate mount, mail network |

Edit the secrets with `sops secrets/hosts/homestation/paperless.yaml`, then flip
the switch and apply with the normal `nix-switch` workflow.

## First run and Pocket ID

On the first deployment, `docs.npham.de` is private and regular Paperless login
is available. Open the local HTTPS hostname and create a superuser with a
recovery password. Keep those credentials: Paperless retains local
authentication for the Django admin and API even when frontend login is later
disabled.

Create a confidential OIDC client in Pocket ID:

- Name: `Paperless`
- Redirect URI: `https://docs.npham.de/accounts/oidc/pocketid/login/callback/`
- PKCE enabled; restrict the client to your Pocket ID account.

Add `oidc-client-id` and `oidc-client-secret` to `paperless.yaml`, set
`sso = true`, and apply. The local superuser remains available at `/admin` for
recovery. The OIDC settings follow Paperless's
[OpenID Connect configuration](https://docs.paperless-ngx.com/advanced_usage/).

## Adding documents

- From a phone, scan with its built-in document scanner or a scan app, then
  upload the resulting PDF or image through the Paperless web interface.
- Upload downloaded PDFs or other supported files through the web interface.
- No scanner or watched-folder mount is configured. `consume` is intentionally
  absent; use the web interface for manual imports.

Apache Tika and Gotenberg are enabled for Office files and `.eml` parsing.
The setup follows Paperless's
[official PostgreSQL, Tika, and Gotenberg Compose configuration](https://github.com/paperless-ngx/paperless-ngx/blob/dev/docker/compose/docker-compose.postgres-tika.yml).

## Proton Mail intake

Proton Bridge runs natively through the NixOS `services.protonmail-bridge`
module ([`protonmail-bridge.nix`](../configurations/nixos/homestation/protonmail-bridge.nix)).
It is a lingering user service started with the user manager instead of a
graphical session, and it waits until the user's `pass` store exists.

Bridge only listens on `127.0.0.1:1143`, and its TLS certificate is issued for
`127.0.0.1`. With `mailIntake = true`:

1. A socket-activated `systemd-socket-proxyd` unit
   (`paperless-bridge-proxy.socket`) listens on `10.233.254.1:1143`, the
   gateway of the internal `paperless-mail` Docker network, and forwards to
   Bridge on loopback. The firewall allows the port only on `br-pmail0`.
2. Only the Paperless `web` service joins that internal network.
3. A non-root `socat` container (`imap-relay`) shares the `web` network
   namespace and maps `127.0.0.1:1143` there to the gateway. Paperless connects
   to `127.0.0.1`, so certificate verification matches.

### One-time Bridge setup

In a homestation shell, as the homestation user. The GPG key must be usable
without an interactive passphrase, or Bridge cannot start after a reboot.

```sh
gpg --list-secret-keys --keyid-format LONG
pass init <GPG-key-fingerprint>
protonmail-bridge -c   # login, then `info` for the IMAP username/password; exit
systemctl --user start protonmail-bridge.service
```

Run the interactive CLI only while the service is stopped; both use the same
profile lock. Keep the Bridge IMAP username and password private; they are
different from the Proton account password.

Read the public certificate from the running listener and add it to
`paperless.yaml` as `bridge-certificate` (a YAML block scalar). Do not copy
Bridge's private key.

```sh
openssl s_client -connect 127.0.0.1:1143 -starttls imap </dev/null 2>/dev/null \
  | openssl x509
```

Set `mailIntake = true` and apply. In Paperless, create the mail account with
host `127.0.0.1`, port `1143`, security `STARTTLS`, and the Bridge credentials.

Use the additional Proton address for receipts and paperwork. Create a Proton
folder for archive mail and a Proton filter that moves messages for that
address into it. In Paperless, create a mail rule that selects only this
folder. The folder limits what Paperless imports; the Bridge connection itself
still has access to the whole Proton account. See Proton's
[address guide](https://proton.me/support/addresses-and-aliases) and
[Bridge CLI guide](https://proton.me/support/bridge-cli-guide). Proton
documents Ubuntu and Fedora as supported Linux distributions; the NixOS
package is self-supported.

## Backup and recovery

The local backup stops `arion-paperless.service` while it stages Paperless's
`data` and `media` directories. It also creates a compressed PostgreSQL dump
at `postgres/paperless.sql.gz`. The Valkey queue is disposable and is not
backed up. Bridge's profile and the `pass` store live in the homestation
user's home directory and are not part of the Paperless backup; keep the GPG
key and Proton recovery methods so Bridge can be signed in again. See the
[homestation backup and recovery guide](homestation-backup-recovery.md).
