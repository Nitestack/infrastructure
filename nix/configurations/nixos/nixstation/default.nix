# ╭──────────────────────────────────────────────────────────╮
# │ NixOS Desktop Configuration                              │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  pkgs,
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
    self.nixosModules.linux-only
    self.nixosModules.gui-only

    self.nixosModules.audio
    self.nixosModules.backlight
    self.nixosModules.boot
    self.nixosModules.gnome
    self.nixosModules.hyprland
    self.nixosModules.sddm
    self.nixosModules.steam
  ];

  # ── Home Manager ──────────────────────────────────────────────────────
  home-manager.users.${meta.username} = {
    imports = [ (self + /configurations/home/desktop.nix) ];
  };

  # Packages
  environment.systemPackages = with pkgs; [
    # Packages
    protonvpn-cli

    # Apps
    endeavour
    ente-auth
    protonmail-desktop
    # protonvpn-gui # INFO: A dependency is marked broken
    stremio
    wasistlos

    # NixOS
    gnome-system-monitor
    nautilus
  ];

  # Proton VPN
  security.sudo.extraRules = [
    {
      users = [ meta.username ];
      commands = [
        {
          command = "${pkgs.protonvpn-cli}/bin/protonvpn";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # Virtualization
  programs.virt-manager.enable = true;
  virtualisation = {
    libvirtd.enable = true;
    docker.enable = true;
  };

  # Services
  services = {
    blueman.enable = true;
    playerctld.enable = true;
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.Experimental = true;
  };

  # Network
  networking = {
    networkmanager.enable = true;
    hostName = "nixstation";
    # Spotify
    firewall = {
      allowedTCPPorts = [ 57621 ]; # sync local tracks from fs with mobile devices in the same network
      allowedUDPPorts = [ 5353 ]; # enables discovery of Spotify Connect devices
    };
  };

  # Hardware Time
  time.hardwareClockInLocalTime = true;
}
