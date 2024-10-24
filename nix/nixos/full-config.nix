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
    ./gnome.nix
    ./hyprland.nix
    ./sddm.nix
  ];

  # ── Home Manager ──────────────────────────────────────────────────────
  home-manager.users.${meta.username} = import ../home-manager/full-home.nix;

  # ── System ────────────────────────────────────────────────────────────

  # Packages
  environment.systemPackages = with pkgs; [
    # Packages
    ntfs3g
    ueberzugpp

    # Apps
    bitwarden-desktop
    google-chrome
    jetbrains.idea-ultimate
    jetbrains.webstorm
    rpi-imager
    signal-desktop
    spotify
    webcord
    zed-editor

    # NixOS
    gnome-system-monitor
    nautilus
    vlc
  ];

  # Virtualization
  programs.virt-manager.enable = true;
  virtualisation = {
    libvirtd.enable = true;
    docker.enable = true;
  };

  # Services
  services = {
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

  # Mount Windows Drive (for dual boot systems)
  boot.supportedFilesystems = [ "ntfs" ];
  fileSystems."/mnt/windows" = {
    device = "/dev/nvme0n1p3"; # Depending on your system
    fsType = "ntfs-3g";
    options = [
      "rw"
      "uid=1000"
    ];
  };
}
