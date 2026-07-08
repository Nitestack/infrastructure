# OpenTofu: Cloudflare DNS

Manages exactly one Cloudflare DNS record: the `*.npham.de` CNAME that routes
public homelab traffic into the Cloudflare Tunnel. The tunnel itself is
managed natively by NixOS (`modules/nixos/homestation-homelab/cloudflared.nix`),
not by this config.

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

Needed only when re-bootstrapping on a new machine, or if `local.zone_id` in
`dns.tf` ever needs to change:

```sh
# Zone ID
curl -s -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  "https://api.cloudflare.com/client/v4/zones?name=npham.de" | jq '.result[] | {id, name}'

# Existing DNS record ID (for import)
curl -s -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  "https://api.cloudflare.com/client/v4/zones/<ZONE_ID>/dns_records?type=CNAME&name=*.npham.de" \
  | jq '.result[] | {id, name, content, proxied}'
```

## Adopting an already-existing record

If the wildcard record already exists in Cloudflare (created by hand), import
it instead of applying blind — applying without importing first will error
on a duplicate record:

```sh
tofu import cloudflare_dns_record.tunnel_wildcard <ZONE_ID>/<RECORD_ID>
tofu plan   # must show "No changes" before you apply
```
