# OpenTofu: Cloudflare Edge

Manages Cloudflare-side edge state for homestation:

- `*.npham.de` proxied CNAME -> `f4320d83-db5c-4280-808f-93822cd737c5.cfargotunnel.com`
- zone setting `always_use_https = on`

Cloudflare Tunnel ingress is not managed in OpenTofu. Source of truth is NixOS:

- generator: `modules/nixos/homestation-homelab/cloudflared.nix`
- host wiring: `configurations/nixos/homestation/default.nix`

That NixOS config generates wildcard tunnel ingress to
`http://127.0.0.1:<caddy.tunnelPort>`, not `https://caddy:443`.

See `docs/superpowers/specs/2026-07-08-opentofu-cloudflare-dns-design.md` for
the full design and rationale.

## Setup

Enter the repo's dev shell so `tofu` is on `PATH`:

```sh
nix develop
```

Get the Cloudflare API token (same token Caddy uses for DNS-01 ACME) from
sops:

```sh
export CLOUDFLARE_API_TOKEN=$(sops -d --extract '["cloudflare"]["api-token"]' secrets/hosts/homestation/infra.yaml)
```

## Everyday use

```sh
cd opentofu/cloudflare
tofu init
tofu plan
tofu apply
```

## Looking up the zone ID or an existing record ID

Needed only when re-bootstrapping on new machine, or if `local.zone_id` in
`dns.tf` ever changes:

```sh
# Zone ID
curl -s -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  "https://api.cloudflare.com/client/v4/zones?name=npham.de" | jq '.result[] | {id, name}'

# Existing wildcard DNS record ID (for import)
curl -s -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  "https://api.cloudflare.com/client/v4/zones/<ZONE_ID>/dns_records?type=CNAME&name=*.npham.de" \
  | jq '.result[] | {id, name, content, proxied}'

# Existing Always Use HTTPS zone setting
curl -s -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  "https://api.cloudflare.com/client/v4/zones/<ZONE_ID>/settings/always_use_https" \
  | jq '.result | {id, value, editable}'
```

## Adopting an already-existing record

If the wildcard record already exists in Cloudflare (created by hand), import
it instead of applying blind — applying without importing first will error
on a duplicate record:

```sh
tofu import cloudflare_dns_record.tunnel_wildcard <ZONE_ID>/<RECORD_ID>
tofu import cloudflare_zone_setting.always_use_https <ZONE_ID>/always_use_https
tofu plan   # must show "No changes" before you apply
```
