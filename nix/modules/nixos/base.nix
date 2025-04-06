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
  ];

  # ── Nix ───────────────────────────────────────────────────────────────
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
        trusted-users = [
          "root"
          (if pkgs.stdenv.isDarwin then meta.username else "@wheel")
        ];
      };
      channel.enable = false;
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
  users.users.${meta.username} = {
    description = meta.description;
    home = "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/${meta.username}";
  };

  # ── Zsh ───────────────────────────────────────────────────────────────
  programs.zsh.enable = true;
  # zsh completion for system packages
  environment.pathsToLink = [ "/share/zsh" ];

  # ── Programs ──────────────────────────────────────────────────────────
  programs.tmux.enable = true;

  # ── Localization ──────────────────────────────────────────────────────
  time.timeZone = "Europe/Berlin";
}
