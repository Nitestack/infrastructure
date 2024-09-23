# ╭──────────────────────────────────────────────────────────╮
# │ System                                                   │
# ╰──────────────────────────────────────────────────────────╯
{
  inputs,
  config,
  lib,
  pkgs,
  meta,
  ...
}:
{
  # nix
  documentation.nixos.enable = false;
  nixpkgs.config.allowUnfree = true;
  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
      settings = {
        experimental-features = "nix-command flakes";
        # Opinionated: disable global registry
        flake-registry = "";
        # Workaround for https://github.com/NixOS/nix/issues/9574
        nix-path = config.nix.nixPath;
        auto-optimise-store = true;
      };
      # Opinionated: disable channels
      channel.enable = false;

      # Opinionated: make flake registry and nix path match flake inputs
      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    };

  # virtualization
  programs.virt-manager.enable = true;
  virtualisation = {
    libvirtd.enable = true;
    docker.enable = true;
  };

  # packages
  environment.systemPackages = with pkgs; [
    gcc

    # Essential
    chezmoi
    curl
    git
    gum
    python3
    volta
    wget
    rustup

    # Packages
    delta
    lazydocker
    lazygit
    ueberzugpp
    unzip

    # Apps
    bitwarden-desktop
    discord
    google-chrome
    jetbrains.idea-ultimate
    jetbrains.webstorm
    spotify
    zed-editor

    # NixOS
    gnome-system-monitor
    nautilus
    nixd
    nixfmt-rfc-style
    vlc
  ];

  # services
  services = {
    openssh = {
      enable = true;
      settings = {
        # Opinionated: forbid root login through SSH.
        PermitRootLogin = "no";
        # Opinionated: use keys only.
        # Remove if you want to SSH using passwords
        PasswordAuthentication = false;
      };
    };
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

  # network
  networking = {
    networkmanager.enable = true;
    hostName = meta.hostname;
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.Experimental = true;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
