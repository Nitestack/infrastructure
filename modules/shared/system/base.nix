# ╭──────────────────────────────────────────────────────────╮
# │ Shared System Configuration                              │
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

  nix-flake-update = pkgs.writeShellApplication {
    name = "nix-flake-update";
    text = ''nix flake update --commit-lock-file --flake ~/nix-config "$@"'';
  };
in
{
  imports = [
    ./options.nix
    ./nushell.nix
  ];

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
        flake-registry = "";
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

  environment.systemPackages = with pkgs; [
    caddy
    curl
    python3
    wget

    ansible
    devenv
    duf
    ffmpeg
    ncdu
    openssl
    rclone
    tree
    unzip

    nix-flake-update
    git-lfs
    nix-prefetch-git
    nixfmt
  ];

  home-manager = {
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit meta theme;
    };
  };

  users.users.${meta.username} = {
    inherit (meta) description;
    home = "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/${meta.username}";
  };

  programs = {
    gnupg.agent = {
      enable = true;
    }
    // lib.optionalAttrs (!pkgs.stdenv.isDarwin) {
      settings = {
        default-cache-ttl = 86400;
        max-cache-ttl = 86400;
      };
    };
    tmux.enable = true;
    zsh.enable = true;
  };

  time.timeZone = "Europe/Berlin";
}
