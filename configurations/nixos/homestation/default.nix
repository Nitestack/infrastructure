# ╭──────────────────────────────────────────────────────────╮
# │ NixOS Server Configuration                               │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  config,
  pkgs,
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

  # Virtualization
  virtualisation = {
    oci-containers.backend = "docker";
    docker.autoPrune = {
      enable = true;
      randomizedDelaySec = "1h";
      flags = [
        "--all"
        "--filter=until=720h"
      ];
    };
  };

  # Packages
  environment.systemPackages = with pkgs; [
    ghostty.terminfo
  ];

  # Allowed SSH clients
  users.users.${meta.username}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAE51+iQSvnNjWATieu+alWv351eNsQmF7jRXUvty/ZH nhan@nixstation"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO6egS4kyK6TIE4+3nZUonv3BtDR9tnyCzMn9RO5Q3fJ nhan@winstation"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINqfwTlUnVgk7oLwIy5b9wFn1yShMOYU7eYXqnpK4VD0 nhan@wslstation"
  ];
}
