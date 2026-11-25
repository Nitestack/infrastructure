# Security and TLS settings every Cloudflare zone in this repository shares.
# Zone-specific DNS records live in the root module, one file per zone.

terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

locals {
  settings = {
    ssl                      = "strict"
    always_use_https         = "on"
    automatic_https_rewrites = "on"
    min_tls_version          = "1.2"
    tls_1_3                  = "on"
  }

  # Cloudflare adds CAA records for its own Universal SSL CAs automatically,
  # so only issuers for certificates obtained outside Cloudflare are listed.
  caa = merge(
    { for issuer in var.caa_issuers : "issue-${issuer}" => { tag = "issue", value = issuer } },
    { iodef = { tag = "iodef", value = "mailto:${var.caa_iodef_email}" } },
  )
}

resource "cloudflare_zone_setting" "this" {
  for_each = local.settings

  zone_id    = var.zone_id
  setting_id = each.key
  value      = each.value
}

resource "cloudflare_zone_setting" "hsts" {
  zone_id    = var.zone_id
  setting_id = "security_header"
  value = {
    strict_transport_security = {
      enabled            = true
      max_age            = var.hsts_max_age
      include_subdomains = true
      preload            = false
      nosniff            = true
    }
  }
}

resource "cloudflare_zone_dnssec" "this" {
  zone_id = var.zone_id
  status  = "active"
}

resource "cloudflare_dns_record" "caa" {
  for_each = local.caa

  zone_id = var.zone_id
  name    = var.zone_name
  type    = "CAA"
  ttl     = 1
  data = {
    flags = 0
    tag   = each.value.tag
    value = each.value.value
  }
}
