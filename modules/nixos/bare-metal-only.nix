# ╭──────────────────────────────────────────────────────────╮
# │ Bare Metal Only Configuration                            │
# ╰──────────────────────────────────────────────────────────╯
{
  config,
  flake,
  lib,
  ...
}:
let
  inherit (flake.inputs) self;
  inherit (config) meta;
in
{
  imports = [
    self.nixosModules.boot
  ];

  # User Groups
  users.users.${meta.username} = {
    extraGroups = [ "networkmanager" ];
    # SSH clients authorized on both bare-metal hosts.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO6egS4kyK6TIE4+3nZUonv3BtDR9tnyCzMn9RO5Q3fJ winstation"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINqfwTlUnVgk7oLwIy5b9wFn1yShMOYU7eYXqnpK4VD0 wslstation"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7L6GoOmhnNLml0F4i6kFFNSyWZ3uF1LeJ+MpDk22JT phonestation"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILXfvlV4sodQ/69iAmNiHBqv6ge6yTSjIhmvgedqQjoH ipadstation"
    ];
  };

  security.pam.services.sshd.showMotd = lib.mkForce false;

  # Services
  services = {
    openssh = {
      enable = true;
      settings = {
        PrintLastLog = false;
        # Opinionated: forbid root login through SSH.
        PermitRootLogin = "no";
        # Opinionated: use keys only.
        # Remove if you want to SSH using passwords
        PasswordAuthentication = false;
      };
    };
    tailscale.enable = true;
  };

  # Virtualization
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  # Networking
  networking = {
    networkmanager.enable = true;
    nftables.enable = true;
  };
}
