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
  inherit (flake) inputs;
  inherit (inputs) self;
  inherit (config) meta;
in
{
  imports = [
    ./hardware-configuration.nix

    inputs.arion.nixosModules.arion
    self.nixosModules.base
    self.nixosModules.bare-metal-only
    self.nixosModules.homelab
    ./rendered-files.nix
    ./sops.nix
    ./homelab/audiomuse-ai.nix
    ./homelab/adguard-home.nix
    ./homelab/adventure-log.nix
    ./homelab/beets
    ./homelab/beszel.nix
    ./homelab/calibre-web-automated.nix
    ./homelab/ente
    ./homelab/freshrss.nix
    ./homelab/glance
    ./homelab/immich.nix
    ./homelab/it-tools.nix
    ./homelab/navidrome.nix
    ./homelab/nextcloud.nix
    ./homelab/obsidian-livesync.nix
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

  # ── Graphics ──────────────────────────────────────────────────────────
  # Intel UHD 630 (i5-9500T): VAAPI for QSV transcoding + OpenVINO for
  # Immich's machine-learning acceleration.
  hardware.graphics = {
    enable = true;
    extraPackages = [ pkgs.intel-media-driver ];
  };

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

  homelab = {
    enable = true;
    domain = "npham.de";
    lanAddress = "192.168.178.20";
    libraries.music = {
      path = "/var/lib/homelab/music";
      owner = meta.username;
      group = "users";
    };
    smtp = {
      host = "smtp.protonmail.ch";
      port = 587;
      security = "starttls";
      from = "noreply@npham.de";
      username = "noreply@npham.de";
    };
    cloudflared.tunnelId = "f4320d83-db5c-4280-808f-93822cd737c5";
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
  services.journald.extraConfig = ''
    SystemMaxUse=2G
    SystemKeepFree=50G
    MaxRetentionSec=30day
  '';

  systemd.tmpfiles.rules = [
    "f /home/${meta.username}/.hushlogin 0644 ${meta.username} users -"
  ];

  # Packages
  environment.systemPackages = with pkgs; [
    ghostty.terminfo
    intel-gpu-tools
  ];

  # Allowed SSH clients
  users.users.${meta.username}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAE51+iQSvnNjWATieu+alWv351eNsQmF7jRXUvty/ZH nhan@nixstation"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO6egS4kyK6TIE4+3nZUonv3BtDR9tnyCzMn9RO5Q3fJ nhan@winstation"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINqfwTlUnVgk7oLwIy5b9wFn1yShMOYU7eYXqnpK4VD0 nhan@wslstation"
    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBNRYpZjGy6COglYwmsF/RUnbK03WHBKXODo4+8De+olUfUKNsVsFAwvrJQHR51/d5UijZPuaVbumSxbr5u1O1Fo= nhan@phonestation"
  ];
}
