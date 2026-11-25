output "dnssec_ds_records" {
  description = "DS records to enter at each registrar; null where DNSSEC is disabled."
  value = {
    "npham.de"  = module.npham_de_baseline.ds_record
    "nhanph.am" = module.nhanph_am_baseline.ds_record
  }
}
