# ╭──────────────────────────────────────────────────────────╮
# │ Bare Metal Only Configuration                            │
# ╰──────────────────────────────────────────────────────────╯
{ config, flake, ... }:
let
  inherit (flake.inputs) self;
  inherit (config) meta;
in
{
  imports = [
    self.nixosModules.boot
  ];

  # User Groups
  users.users.${meta.username}.extraGroups = [
    "networkmanager"
  ];

  # Services
  services.openssh = {
    enable = true;
    settings = {
      # Opinionated: forbid root login through SSH.
      PermitRootLogin = "no";
      # Opinionated: use keys only.
      # Remove if you want to SSH using passwords
      PasswordAuthentication = false;
    };
  };

  # Virtualization
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  # Networking
  networking.networkmanager.enable = true;
}
