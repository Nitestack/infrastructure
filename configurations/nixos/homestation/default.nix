# ╭──────────────────────────────────────────────────────────╮
# │ NixOS Server Configuration                               │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  config,
  ...
}:
let
  inherit (flake.inputs) self;
  inherit (config) meta;
in
{
  imports = [
    ./hardware-configuration.nix

    self.nixosModules.base
    self.nixosModules.bare-metal-only
  ];

  # ── Networking ────────────────────────────────────────────────────────
  networking.hostName = "homestation";

  # ── Home Manager ──────────────────────────────────────────────────────
  home-manager.users.${meta.username} = {
    imports = [ (self + /configurations/home/server.nix) ];
  };

  # Allowed SSH clients
  users.users.${meta.username}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAE51+iQSvnNjWATieu+alWv351eNsQmF7jRXUvty/ZH nhan@nixos"
  ];
}
