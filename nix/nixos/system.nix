{
  inputs,
  config,
  lib,
  pkgs,
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
        # Enable flakes and new 'nix' command
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

  # dconf
  programs.dconf.enable = true;

  # packages
  environment.systemPackages = with pkgs; [
    git
    wezterm
    ripgrep
    rustup
    nixfmt-rfc-style
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
  };

  # Bootloader
  boot = {
    tmp.cleanOnBoot = true;
    loader = {
      timeout = 2;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  # network
  networking.networkmanager.enable = true;

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.Experimental = true;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
