# ╭──────────────────────────────────────────────────────────╮
# │ NixOS Desktop Configuration                              │
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

  dp2Width = 1920;
in
{
  imports = [
    ./hardware-configuration.nix
    ./sops.nix

    self.nixosModules.base
    self.nixosModules.bare-metal-only
    self.nixosModules.interactive-only

    self.nixosModules.audio
    self.nixosModules.backlight
    self.nixosModules.dank-material-shell
    self.nixosModules.davinci-resolve
    self.nixosModules.flatpak
    self.nixosModules.games
    self.nixosModules.gnome
    self.nixosModules.hyprland
    self.nixosModules.logiops
  ];

  # Monitors
  meta.monitors = [
    {
      name = "DP-2";
      resolution = "${toString dp2Width}x1080";
      refreshRate = 144;
      position = {
        x = 0;
        y = 0;
      };
      backlight = {
        i2cBus = "i2c-7";
        device = "ddcci7";
        busName = "AMDGPU DM aux hw bus 1"; # grep -r "AMDGPU DM aux hw bus" /sys/bus/i2c/devices/i2c-7/name
      };
    }
    {
      name = "DP-1";
      resolution = "1920x1080";
      refreshRate = 200;
      position = {
        x = dp2Width;
        y = 0;
      };
      isDefault = true;
      backlight = {
        i2cBus = "i2c-6";
        device = "ddcci6";
        busName = "AMDGPU DM aux hw bus 0"; # grep -r "AMDGPU DM aux hw bus" /sys/bus/i2c/devices/i2c-6/name
      };
    }
  ];

  # ── Home Manager ──────────────────────────────────────────────────────
  home-manager.users.${meta.username} = {
    imports = [ (self + /configurations/home/desktop.nix) ];
  };

  # ── Packages ──────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    # (bottles.override {
    #   removeWarningPopup = true;
    # })
    endeavour
    ente-auth
    flacon
    karere
    kid3
    lutris
    mpv # feishin dependency
    proton-vpn
    stremio-linux-shell
  ];

  # ── Networking ────────────────────────────────────────────────────────
  networking = {
    hostName = "nixstation";
    firewall = {
      allowedTCPPorts = [
        57621 # Spotify: sync local tracks from fs with mobile devices in the same network
        3000 # web development
      ];
      allowedUDPPorts = [ 5353 ]; # Spotify: enables discovery of Spotify Connect devices
    };
  };

  # User Groups
  users.users.${meta.username}.extraGroups = [
    "audio"
    "libvirtd"
    "video"
  ];

  # Services
  programs = {
    gnupg.agent.pinentryPackage = pkgs.pinentry-gnome3;
    virt-manager.enable = true;
  };

  # Virtualization
  virtualisation = {
    libvirtd.enable = true;
    docker.autoPrune.flags = [
      "--all"
      "--filter=until=168h"
    ];
  };

  services = {
    blueman.enable = true;
    playerctld.enable = true;
    tailscale = {
      useRoutingFeatures = "client";
      extraSetFlags = [ "--accept-routes" ];
    };
    xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
    };
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.Experimental = true;
  };
}
