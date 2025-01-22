# ╭──────────────────────────────────────────────────────────╮
# │ Nix Base Configuration                                   │
# ╰──────────────────────────────────────────────────────────╯
{
  inputs,
  outputs,
  config,
  lib,
  pkgs,
  meta,
  theme,
  ...
}:
let

in
{
  # ── Nix ───────────────────────────────────────────────────────────────
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

  # ── Overlays ──────────────────────────────────────────────────────────
  nixpkgs = {
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
  };

  # ── Packages ──────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    # Essential
    gcc
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
    unzip

    # Nix
    nix-prefetch-git
    nixd
    nixfmt-rfc-style
  ];

  # ── Home Manager ──────────────────────────────────────────────────────
  home-manager = {
    backupFileExtension = "backup";
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = {
      inherit
        inputs
        outputs
        theme
        ;
      meta = meta // {
        # Theme
        cursorTheme = {
          name = "catppuccin-mocha-blue-cursors";
          package = pkgs.catppuccin-cursors.mochaBlue;
          size = 24;
        };
      };
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
    nh = {
      enable = true;
      clean.enable = true;
      flake = "${config.users.users.${meta.username}.home}/.dotfiles/nix";
    };
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
