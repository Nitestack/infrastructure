terraform {
  required_version = ">= 1.6.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.21"
    }
  }
}

# Reads the CLOUDFLARE_API_TOKEN environment variable automatically.
provider "cloudflare" {}
