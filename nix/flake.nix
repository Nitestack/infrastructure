# ╭──────────────────────────────────────────────────────────╮
# │ Nix Flake                                                │
# ╰──────────────────────────────────────────────────────────╯
{
  description = "Nix Configuration for NixOS Desktop and NixOS WSL";

  # ── Inputs ────────────────────────────────────────────────────────────
  inputs = {
    # ── Principle Inputs ──────────────────────────────────────────────────
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Nix Darwin
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # NixOS WSL
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Homebrew
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    # NixOS Unified
    nixos-unified.url = "github:srid/nixos-unified";
    # Flake Parts
    flake-parts.url = "github:hercules-ci/flake-parts";

    # ── Software Inputs ───────────────────────────────────────────────────
    # Flatpak
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
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
    # Zen Browser
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ── Homebrew Taps ─────────────────────────────────────────────────────
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  # ── Outputs ───────────────────────────────────────────────────────────
  outputs =
    inputs:
    inputs.nixos-unified.lib.mkFlake {
      inherit inputs;
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
        "x86_64-darwin"
      ];
      root = ./.;
    };
}
