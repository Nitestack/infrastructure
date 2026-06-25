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
}
