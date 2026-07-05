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
    self.nixosModules.homestation-homelab
    ./sops.nix
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

  homestation.homelab = {
    enable = true;
    domain = "npham.de";
    lanAddress = "192.168.178.20";
    cloudflared.tunnelId = "f4320d83-db5c-4280-808f-93822cd737c5";

    apps.whoami.containers.web = {
      enable = false;
      image = "traefik/whoami:latest";
      edge.enable = true;
      expose = {
        mode = "private";
        host = "whoami.npham.de";
        port = 80;
      };
    };
  };

  # Services
  services.cloudflared = {
    enable = true;
    certificateFile = config.sops.secrets."cloudflared/certificate".path;
    tunnels = {
      "f4320d83-db5c-4280-808f-93822cd737c5" = {
        credentialsFile = config.sops.secrets."cloudflared/credentials".path;
        default = "http_status:404";
      };
    };
  };

  # systemd
  systemd.tmpfiles.rules = [
    "f /home/${meta.username}/.hushlogin 0644 ${meta.username} users -"
  ];

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
