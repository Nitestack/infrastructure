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

  nix-flake-update = pkgs.writeShellScriptBin "nix-flake-update" ''
    #!/usr/bin/env bash

    nix flake update --commit-lock-file --flake ~/.dotfiles/nix $@
  '';
in
{
  # ── Imports ───────────────────────────────────────────────────────────
  imports = [
    self.nixosModules.options
    self.nixosModules.nushell
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
    python3
    wget

    # Packages
    ansible
    duf
    ncdu
    openssl
    tree
    unzip

    # Nix
    nix-flake-update
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

  # ── Programs ──────────────────────────────────────────────────────────
  programs = {
    gnupg.agent.enable = true;
    tmux.enable = true;
    zsh.enable = true;
  };

  # ── Localization ──────────────────────────────────────────────────────
  time.timeZone = "Europe/Berlin";
}
