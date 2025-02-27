# ╭──────────────────────────────────────────────────────────╮
# │ Nix Base Configuration                                   │
# ╰──────────────────────────────────────────────────────────╯
{
  config,
  flake,
  lib,
  pkgs,
  ...
}:
let
  inherit (flake) inputs;
  inherit (inputs) self;
  inherit (config) meta theme;
in
{
  # ── Imports ───────────────────────────────────────────────────────────
  imports = [
    self.nixosModules.options
    self.nixosModules.nh
  ];

  # ── Nix ───────────────────────────────────────────────────────────────
  documentation.nixos.enable = false;
  nixpkgs = {
    config.allowUnfree = true;
    overlays = lib.attrValues self.overlays;
  };
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
        trusted-users = [
          "root"
          (if pkgs.stdenv.isDarwin then meta.username else "@wheel")
        ];
      };
      # Opinionated: disable channels
      channel.enable = false;

      # Opinionated: make flake registry and nix path match flake inputs
      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    };

  # ── Packages ──────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    # Essential
    caddy
    chezmoi
    curl
    git
    gum
    python3
    wget

    # Packages
    ansible
    delta
    lazygit
    openssl
    tree
    unzip

    # Nix
    nix-prefetch-git
    nixfmt-rfc-style
  ];

  # ── Home Manager ──────────────────────────────────────────────────────
  home-manager = {
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit meta theme;
    };
  };

  # ── Users ─────────────────────────────────────────────────────────────
  users = {
    users = {
      ${meta.username} = {
        isNormalUser = true;
        description = meta.description;
        extraGroups = [
          "audio"
          "docker"
          "libvirtd"
          "networkmanager"
          "video"
          "wheel"
        ];
      };
    };
    defaultUserShell = pkgs.zsh;
  };

  # ── Zsh ───────────────────────────────────────────────────────────────
  programs.zsh.enable = true;
  # zsh completion for system packages
  environment.pathsToLink = [ "/share/zsh" ];

  # ── Programs ──────────────────────────────────────────────────────────
  programs = {
    java = {
      enable = true;
    };
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
    tmux.enable = true;
    nix-ld.enable = true;
  };

  # ── Services ──────────────────────────────────────────────────────────
  services = {
    avahi = {
      enable = true;
      nssmdns4 = true; # Enable mDNS for IPv4
      nssmdns6 = true; # Enable mDNS for IPv6
      ipv4 = true; # Ensure IPv4 support
      ipv6 = true; # Ensure IPv6 support
      openFirewall = true; # Open the firewall for Avahi
    };
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

  # ── Localization ──────────────────────────────────────────────────────
  time.timeZone = "Europe/Berlin";
  i18n =
    let
      english = "en_US.UTF-8";
      german = "de_DE.UTF-8";
    in
    {
      defaultLocale = english;
      extraLocaleSettings = {
        LC_ADDRESS = german;
        LC_IDENTIFICATION = german;
        LC_MEASUREMENT = german;
        LC_MONETARY = german;
        LC_NAME = german;
        LC_NUMERIC = german;
        LC_PAPER = german;
        LC_TELEPHONE = german;
        LC_TIME = german;
      };
    };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
