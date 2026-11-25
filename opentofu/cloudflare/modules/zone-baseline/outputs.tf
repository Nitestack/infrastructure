output "ds_record" {
  description = "DS record to enter at the registrar to complete DNSSEC."
  value       = cloudflare_zone_dnssec.this.ds
}
