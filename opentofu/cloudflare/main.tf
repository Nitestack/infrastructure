# Values shared by both zones. They change close to never; keep tunnel_id in
# sync with configurations/nixos/homestation/default.nix by hand.
locals {
  tunnel_id     = "f4320d83-db5c-4280-808f-93822cd737c5"
  tunnel_target = "${local.tunnel_id}.cfargotunnel.com"

  # nhanph.am receives no mail yet, so CA reports go to a working mailbox.
  caa_iodef_email = "contact@npham.de"
}
