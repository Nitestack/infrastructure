output "dnssec_ds_records" {
  description = "DS records to enter at each registrar (name.am for nhanph.am)."
  value = {
    "npham.de"  = module.npham_de_baseline.ds_record
    "nhanph.am" = module.nhanph_am_baseline.ds_record
  }
}
