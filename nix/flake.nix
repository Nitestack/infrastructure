# ╭──────────────────────────────────────────────────────────╮
# │ NIX FLAKE                                                │
# ╰──────────────────────────────────────────────────────────╯
{
  description = "NixOS Configuration of Nitestack";

  # ── Inputs ────────────────────────────────────────────────────────────
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";

    # Hyprswitch
    hyprswitch.url = "github:h3rmt/hyprswitch/release";

    # Hyprspace
    Hyprspace = {
      url = "github:KZDKM/Hyprspace";
      inputs.hyprland.follows = "hyprland";
    };

    # Hyprland Contrib
    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Firefox GNOME Theme
    firefox-gnome-theme = {
      url = "github:rafaelmardojai/firefox-gnome-theme";
      flake = false;
    };
  };

  # ── Outputs ───────────────────────────────────────────────────────────
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      inherit (self) outputs;

      # Supported Systems
      systems = [
        "aarch64-linux"
        "x86_64-linux"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
      overlays = import ./overlays;
      nixosModules = import ./nixos/modules;
      homeManagerModules = import ./home-manager/modules;
      nixosConfigurations =
        let
          meta = import ./config.nix {
            pkgs = import <nixpkgs> {
              config.allowUnfree = true;
            };
          };
        in
        {
          ${meta.hostname} = nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit inputs outputs meta;
            };
            system = "x86_64-linux";
            modules = [
              home-manager.nixosModules.home-manager
              ./nixos/configuration.nix
            ];
          };
        };
    };
}
