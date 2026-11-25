# OpenTofu: Cloudflare Edge

Manages Cloudflare-side DNS and zone settings for both zones:

| Zone | Purpose | File |
|---|---|---|
| `npham.de` | Proton Mail, Vercel projects, homelab wildcard (`*` → tunnel) | `zone-npham-de.tf` |
| `nhanph.am` | Future homelab and personal site; apex currently 302 → `npham.de`, `www` 301 → apex; no mail | `zone-nhanph-am.tf` |

Every zone also gets `modules/zone-baseline`:

- `ssl = strict`, `always_use_https`, `automatic_https_rewrites`, TLS ≥ 1.2, TLS 1.3
- HSTS: six months, `includeSubDomains`, `nosniff`, **no** preload
- DNSSEC on Cloudflare's side (see [DNSSEC](#dnssec))
- CAA: only `letsencrypt.org` (Caddy, Vercel) plus the Universal SSL CAs that
  Cloudflare adds itself; `iodef` reports go to the address in `main.tf`

`nhanph.am` receives no mail: null MX, `v=spf1 -all`, DMARC `p=reject`, and an
empty `*._domainkey` record. Replace these records when mail moves to the
domain.

Cloudflare Tunnel ingress is not managed here. The source of truth is NixOS:
`modules/nixos/homelab/cloudflared.nix` generates wildcard ingress for
`*.${homelab.domain}` to `http://127.0.0.1:<caddy.tunnelPort>`. Until
`homelab.domain` is `nhanph.am`, `*.nhanph.am` reaches the tunnel and gets a 404.

## API token

OpenTofu uses its own token, separate from the Caddy DNS-01 token on
homestation. Create it under *My Profile → API Tokens → Custom token*, scoped to
the zones `npham.de` and `nhanph.am`:

| Permission | Level |
|---|---|
| Zone → Zone | Read |
| Zone → Zone Settings | Edit |
| Zone → DNS | Edit |
| Zone → Single Redirect | Edit |

It is stored in `secrets/operator/opentofu.yaml` (`cloudflare.api-token`),
readable by the administrator key and the workstations. Load it without printing
it or writing plaintext to disk. Process substitution feeds it directly to
`read`; do not replace this with command substitution or a redirect:

```bash
IFS= read -r CLOUDFLARE_API_TOKEN < <(
  sops -d --extract '["cloudflare"]["api-token"]' secrets/operator/opentofu.yaml
)
export CLOUDFLARE_API_TOKEN
trap 'unset CLOUDFLARE_API_TOKEN' EXIT
```

## Everyday use

```sh
nix develop
cd opentofu/cloudflare
tofu init
tofu plan
tofu apply
```

State is local (`terraform.tfstate`, gitignored). Back it up or run OpenTofu
from one machine only; a second machine without the state would try to create
existing objects again.

## Adding a record

Add an entry to the zone's `*_records` map. `name = "@"` is the apex; other
names are relative to the zone. Keep TXT content quoted (`"\"v=...\""`), the
form Cloudflare returns, so plans stay clean.

## Adopting an existing object

Look up its ID, add an `import` block, and require a plan
that shows `0 to change` for the imported object before applying:

```sh
curl -s -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  "https://api.cloudflare.com/client/v4/zones?name=<zone>" | jq '.result[] | {id, name}'

curl -s -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  "https://api.cloudflare.com/client/v4/zones/<ZONE_ID>/dns_records?per_page=100" \
  | jq '.result[] | {id, type, name, content, proxied, comment}'
```

Zone settings and DNSSEC need no import: applying sets them, and they cannot be
destroyed from OpenTofu (removing them from config only drops them from state).

## DNSSEC

Applying enables signing at Cloudflare, but DNSSEC becomes active only once the
DS record is entered at the registrar (`name.am` for `nhanph.am`):

```sh
tofu output dnssec_ds_records
```

Until then Cloudflare reports the zone as `pending`, and every plan shows
`status: "pending" -> "active"` for that zone; that drift is expected and
disappears once the registrar publishes the DS record. Remove the DS record at the
registrar **before** moving a zone away from Cloudflare's nameservers or
disabling DNSSEC here; otherwise the domain stops resolving.
