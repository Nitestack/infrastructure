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
    {
      self,
      nixpkgs,
      home-manager,
      nixos-wsl,
      ...
    }@inputs:
    let
      inherit (self) outputs;

      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
      overlays = import ./overlays;
      nixosConfigurations =
        let
          meta = import ./meta.nix {
            pkgs = import <nixpkgs> {
              config.allowUnfree = true;
            };
          };
          theme = builtins.fromJSON (builtins.readFile ./theme.json);

          specialArgs = {
            inherit
              inputs
              outputs
              meta
              theme
              ;
          };
          modules = [
            home-manager.nixosModules.home-manager
            ./hosts/base
          ];
        in
        {
          ${meta.hostname} = nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            modules = modules ++ [
              ./hosts/desktop
              {
                nix.settings = {
                  substituters = [ "https://wezterm.cachix.org" ];
                  trusted-public-keys = [ "wezterm.cachix.org-1:kAbhjYUC9qvblTE+s7S+kl5XM1zVa4skO+E/1IDWdH0=" ];
                };
              }
            ];
          };
          ${meta.wslHostname} = nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            system = "x86_64-linux";
            modules =
              [
                nixos-wsl.nixosModules.default
              ]
              ++ modules
              ++ [
                ./hosts/wsl
              ];
          };
        };
    };
}
