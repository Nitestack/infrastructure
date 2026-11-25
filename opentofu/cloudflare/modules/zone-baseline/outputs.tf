output "ds_record" {
  description = "DS record to enter at the registrar to complete DNSSEC."
  value       = var.dnssec ? cloudflare_zone_dnssec.this.ds : null
}
