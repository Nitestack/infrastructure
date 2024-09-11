# ╭──────────────────────────────────────────────────────────╮
# │ NIXOS CONFIGURATION                                      │
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

      # Meta Information
      meta = {
        username = "nhan";
        description = "Nhan Pham";
        hostname = "nixstation";
      };
      # Supported Systems
      systems = [
        "aarch64-linux"
        "x86_64-linux"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      # Your custom packages
      # Accessible through 'nix build', 'nix shell', etc
      packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
      # Formatter for your nix files, available through 'nix fmt'
      # Other options beside 'alejandra' include 'nixpkgs-fmt'
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

      overlays = import ./overlays;
      nixosModules = import ./nixos/modules;
      homeManagerModules = import ./home-manager/modules;

      nixosConfigurations = {
        ${meta.hostname} = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs meta;
          };
          system = "x86_64-linux";
          modules = [
            # Home Manager
            home-manager.nixosModules.home-manager
            # Configuration
            ./nixos/configuration.nix
          ];
        };
      };
    };
}
