# ╭──────────────────────────────────────────────────────────╮
# │ Nix Flake                                                │
# ╰──────────────────────────────────────────────────────────╯
{
  description = "Nix Configuration for NixOS (including WSL) and macOS";

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
    # Arion
    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # sops-nix
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ── Software Inputs ───────────────────────────────────────────────────
    # agent-skills-nix
    agent-skills.url = "github:Kyure-A/agent-skills-nix";
    # aix
    aix.url = "github:Nitestack/aix";
    # Apple Fonts
    apple-fonts.url = "github:Lyndeno/apple-fonts.nix";
    # Catppuccin Bat Theme
    catppuccin-bat = {
      url = "github:catppuccin/bat";
      flake = false;
    };
    # Catppuccin Delta Theme
    catppuccin-delta = {
      url = "github:catppuccin/delta";
      flake = false;
    };
    # Catppuccin Nushell Theme
    catppuccin-nushell = {
      url = "github:catppuccin/nushell";
      flake = false;
    };
    # caveman
    caveman = {
      url = "github:JuliusBrussee/caveman";
      flake = false;
    };
    # Codex CLI
    codex-desktop-linux.url = "github:ilysenko/codex-desktop-linux";
    # Dank Material Shell
    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Flatpak
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    # Humanizer
    humanizer = {
      url = "github:blader/humanizer";
      flake = false;
    };
    # Hyprland
    hyprland.url = "github:hyprwm/Hyprland";
    # Hyprland Contrib
    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # LLM Agents
    llm-agents-nix = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Matt Pocock's skills
    matt-pocock-skills = {
      url = "github:mattpocock/skills";
      flake = false;
    };
    # OpenCode Vim
    opencode-vim = {
      url = "github:leohenon/opencode-vim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Orca
    orca-nix = {
      url = "github:kevinpita/orca-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Spicetify
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # split-monitor-workspaces
    split-monitor-workspaces = {
      url = "github:zjeffer/split-monitor-workspaces";
      flake = false;
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
      ];
      root = ./.;
    };
}
