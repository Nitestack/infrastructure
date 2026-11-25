variable "zone_id" {
  description = "Cloudflare zone ID."
  type        = string
}

variable "zone_name" {
  description = "Zone apex name, for example npham.de."
  type        = string
}

variable "caa_issuers" {
  description = "Certificate authorities allowed besides Cloudflare's own Universal SSL CAs."
  type        = list(string)
  default     = ["letsencrypt.org"]
}

variable "caa_iodef_email" {
  description = "Address CAs report policy violations to. Must receive mail."
  type        = string
}

variable "hsts_max_age" {
  description = "HSTS max-age in seconds. Defaults to six months."
  type        = number
  default     = 15552000
}
