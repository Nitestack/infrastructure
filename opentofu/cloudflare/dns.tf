# These three values are hardcoded on purpose, not generated from the Nix
# config. They change close to never (a domain or tunnel migration). Keep
# domain and tunnel_id in sync with configurations/nixos/homestation/default.nix
# by hand if either ever changes.
locals {
  domain    = "npham.de"
  tunnel_id = "f4320d83-db5c-4280-808f-93822cd737c5"
  # Filled in during Task 4 by looking up the real zone ID via the Cloudflare API.
  zone_id = "REPLACE_WITH_ZONE_ID"
}

# Routes all *.npham.de traffic into the Cloudflare Tunnel that cloudflared
# (managed natively by NixOS, see modules/nixos/homestation-homelab/cloudflared.nix)
# terminates on homestation. Every homestation.homelab app with
# expose.mode = "public" is reachable through this single wildcard record.
resource "cloudflare_dns_record" "tunnel_wildcard" {
  zone_id = local.zone_id
  name    = "*"
  type    = "CNAME"
  content = "${local.tunnel_id}.cfargotunnel.com"
  proxied = true
  ttl     = 1 # required to be 1 (automatic) when proxied = true
}
