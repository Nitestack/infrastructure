# ╭──────────────────────────────────────────────────────────╮
# │ NIX FLAKE                                                │
# ╰──────────────────────────────────────────────────────────╯
{
  description = "Nix Configuration for NixOS Desktop and NixOS WSL";

  # ── Inputs ────────────────────────────────────────────────────────────
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # NixOS WSL
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flake Parts
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Hyprland Contrib
    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Spicetify
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Tmux SessionX
    tmux-sessionx.url = "github:omerxx/tmux-sessionx";

    # WezTerm
    wezterm.url = "github:wez/wezterm?dir=nix";

    # Zen Browser
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # ── Outputs ───────────────────────────────────────────────────────────
  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./hosts
      ];
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      perSystem =
        {
          pkgs,
          system,
          ...
        }:
        {
          formatter = pkgs.nixfmt-rfc-style;
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ (import ./overlays) ];
          };
        };
    };
}
