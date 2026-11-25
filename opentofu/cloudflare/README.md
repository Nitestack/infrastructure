# OpenTofu: Cloudflare Edge

Manages Cloudflare-side DNS and zone settings for both zones:

| Zone | Purpose | File |
|---|---|---|
| `npham.de` | Proton Mail, Vercel projects, homelab wildcard (`*` → tunnel) | `zone-npham-de.tf` |
| `nhanph.am` | Future homelab and personal site; apex currently 302 → `npham.de`, `www` 301 → apex; no mail | `zone-nhanph-am.tf` |

Every zone also gets `modules/zone-baseline`:

- `ssl = strict`, `always_use_https`, `automatic_https_rewrites`, TLS ≥ 1.2, TLS 1.3
- HSTS: six months, `includeSubDomains`, `nosniff`, **no** preload
- DNSSEC signing, unless the zone opts out (see [DNSSEC](#dnssec))
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
homestation. Required permissions, creation, and rotation are in
[`docs/cloudflare-domains.md`](../../docs/cloudflare-domains.md#opentofu-api-token).
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

`zone-baseline` signs each zone unless it sets `dnssec = false` (`npham.de`: the
registrar cannot submit DNSSEC data for `.de`). Publishing the DS record at the
registrar, verifying the chain, and the order of steps before leaving Cloudflare
are in [`docs/cloudflare-domains.md`](../../docs/cloudflare-domains.md#dnssec).
Until the DS is live, plans show `status: "pending" -> "active"` for the zone;
that drift is expected.
