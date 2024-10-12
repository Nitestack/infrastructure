# ╭──────────────────────────────────────────────────────────╮
# │ System                                                   │
# ╰──────────────────────────────────────────────────────────╯
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

  # packages
  environment.systemPackages = with pkgs; [
    # Essential
    gcc
    chezmoi
    curl
    git
    gum
    python3
    volta
    wget
    rustup

    # Packages
    bc # for TokyoNight TMUX
    delta
    lazydocker
    lazygit
    oh-my-posh
    openssl
    unzip

    # Nix
    nixd
    nixfmt-rfc-style
  ];

  # openssh
  services.openssh = {
    enable = true;
    settings = {
      # Opinionated: forbid root login through SSH.
      PermitRootLogin = "no";
      # Opinionated: use keys only.
      # Remove if you want to SSH using passwords
      PasswordAuthentication = false;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
