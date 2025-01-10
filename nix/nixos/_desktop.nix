# ╭──────────────────────────────────────────────────────────╮
# │ NIXOS FULL CONFIGURATION                                 │
# ╰──────────────────────────────────────────────────────────╯
{
  pkgs,
  meta,
  ...
}:
{
  imports = [
    /etc/nixos/hardware-configuration.nix

    ./audio.nix
    ./backlight.nix
    ./gnome.nix
    ./hyprland.nix
    ./sddm.nix
    ./steam.nix
  ];

  # ── Home Manager ──────────────────────────────────────────────────────
  home-manager.users.${meta.username} = import ../home-manager/_desktop.nix;

  # ── System ────────────────────────────────────────────────────────────

  # Packages
  environment.systemPackages = with pkgs; [
    # Packages
    ntfs3g
    ueberzugpp

    # Apps
    bitwarden-desktop
    endeavour
    google-chrome
    jetbrains.idea-ultimate
    jetbrains.webstorm
    nextcloud-client
    protonmail-desktop
    protonvpn-gui
    rpi-imager
    signal-desktop
    spotify
    stremio
    vesktop

    # NixOS
    gnome-system-monitor
    nautilus
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
    xserver = {
      enable = true;
      excludePackages = with pkgs; [ xterm ];
    };
    playerctld.enable = true;
  };

  # Bootloader
  boot = {
    tmp.cleanOnBoot = true;
    loader = {
      timeout = 60;
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        theme = (
          pkgs.sleek-grub-theme.override {
            withStyle = "dark";
            withBanner = "Boot Manager";
          }
        );
        efiSupport = true;
        useOSProber = true;
        device = "nodev";
        gfxmodeEfi = "1920x1080,auto";
      };
    };
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
    hostName = meta.hostname;
  };

  # Hardware Time
  time.hardwareClockInLocalTime = true;
}
