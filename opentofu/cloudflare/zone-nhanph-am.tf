# nhanph.am: future home of the homelab and personal website. Until then the
# apex redirects to npham.de. The zone sends and receives no mail.
locals {
  nhanph_am = {
    name    = "nhanph.am"
    zone_id = "750bac86e15bdd22e273a5c13ff0a87f"
  }

  nhanph_am_records = {
    # Homelab: answers 404 from cloudflared until homelab.domain switches.
    tunnel_wildcard = { type = "CNAME", name = "*", content = local.tunnel_target, proxied = true }

    # Placeholder origins: these hosts only exist for the redirect rules below.
    # 100:: is the IPv6 discard prefix (RFC 6666) and never receives traffic.
    apex_redirect = { type = "AAAA", name = "@", content = "100::", proxied = true, comment = "Redirect only" }
    www_redirect  = { type = "AAAA", name = "www", content = "100::", proxied = true, comment = "Redirect only" }

    # No mail: null MX (RFC 7505), no permitted senders, reject spoofed mail,
    # and revoke any DKIM selector.
    null_mx    = { type = "MX", name = "@", content = ".", priority = 0, comment = "No mail" }
    spf        = { type = "TXT", name = "@", content = "\"v=spf1 -all\"", comment = "No mail" }
    dmarc      = { type = "TXT", name = "_dmarc", content = "\"v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s\"", comment = "No mail" }
    dkim_empty = { type = "TXT", name = "*._domainkey", content = "\"v=DKIM1; p=\"", comment = "No mail" }
  }
}

module "nhanph_am_baseline" {
  source = "./modules/zone-baseline"

  zone_id         = local.nhanph_am.zone_id
  zone_name       = local.nhanph_am.name
  caa_iodef_email = local.caa_iodef_email
}

resource "cloudflare_dns_record" "nhanph_am" {
  for_each = local.nhanph_am_records

  zone_id  = local.nhanph_am.zone_id
  name     = each.value.name == "@" ? local.nhanph_am.name : "${each.value.name}.${local.nhanph_am.name}"
  type     = each.value.type
  content  = each.value.content
  priority = lookup(each.value, "priority", null)
  proxied  = lookup(each.value, "proxied", false)
  comment  = lookup(each.value, "comment", null)
  ttl      = 1 # automatic; required when proxied
}

# Single Redirects. Once a rule matches, later rules are skipped.
resource "cloudflare_ruleset" "nhanph_am_redirects" {
  zone_id = local.nhanph_am.zone_id
  name    = "Redirects"
  kind    = "zone"
  phase   = "http_request_dynamic_redirect"

  rules = [
    {
      ref         = "www_to_apex"
      description = "www.nhanph.am -> nhanph.am"
      expression  = "(http.host eq \"www.${local.nhanph_am.name}\")"
      action      = "redirect"
      action_parameters = {
        from_value = {
          status_code           = 301
          preserve_query_string = true
          target_url = {
            expression = "concat(\"https://${local.nhanph_am.name}\", http.request.uri.path)"
          }
        }
      }
    },
    {
      # Temporary (302) until the personal website lives on this apex.
      ref         = "apex_to_npham_de"
      description = "nhanph.am -> npham.de (temporary)"
      expression  = "(http.host eq \"${local.nhanph_am.name}\")"
      action      = "redirect"
      action_parameters = {
        from_value = {
          status_code           = 302
          preserve_query_string = true
          target_url = {
            expression = "concat(\"https://${local.npham_de.name}\", http.request.uri.path)"
          }
        }
      }
    },
  ]
}
