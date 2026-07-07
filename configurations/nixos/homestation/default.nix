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

    flake.inputs.arion.nixosModules.arion
    self.nixosModules.base
    self.nixosModules.bare-metal-only
    self.nixosModules.homestation-homelab
    ./rendered-files.nix
    ./sops.nix
    ./homelab/adguard-home.nix
    ./homelab/beets.nix
    ./homelab/beszel.nix
    ./homelab/calibre-web-automated.nix
    ./homelab/freshrss.nix
    ./homelab/glance.nix
    ./homelab/it-tools.nix
    ./homelab/navidrome.nix
    ./homelab/pocket-id.nix
    ./homelab/prowlarr.nix
    ./homelab/rdtclient.nix
    ./homelab/shelfmark.nix
    ./homelab/vaultwarden.nix
    ./homelab/wealthfolio.nix
    ./homelab/yamtrack.nix
    ./tailscale.nix
  ];

  # ── Networking ────────────────────────────────────────────────────────
  networking.hostName = "homestation";

  # ── Home Manager ──────────────────────────────────────────────────────
  home-manager.users.${meta.username} = {
    imports = [ (self + /configurations/home/server.nix) ];
  };

  # Virtualization
  virtualisation = {
    arion.backend = "docker";
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
    libraries.music.path = "/mnt/data/music";
    smtp = {
      host = "smtp.protonmail.ch";
      port = 587;
      security = "starttls";
      from = "noreply@npham.de";
      username = "noreply@npham.de";
    };
    cloudflared.tunnelId = "f4320d83-db5c-4280-808f-93822cd737c5";
    cloudflared.wildcardIngress = true;
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
    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBNRYpZjGy6COglYwmsF/RUnbK03WHBKXODo4+8De+olUfUKNsVsFAwvrJQHR51/d5UijZPuaVbumSxbr5u1O1Fo= nhan@phonestation"
  ];
}
