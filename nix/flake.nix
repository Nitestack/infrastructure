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

    # Hyprland
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    # Hyprland Plugins
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    # ags
    ags.url = "github:Aylur/ags";

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

      meta = {
        username = "nhan";
        description = "Nhan Pham";
        hostname = "nixstation";
      };

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
            {
              networking.hostName = meta.hostname;
              home-manager = {
                backupFileExtension = "backup";
                useUserPackages = true;
                useGlobalPkgs = true;
                extraSpecialArgs = {
                  inherit inputs outputs meta;
                };
                users.${meta.username} = import ./home-manager/home.nix;
              };
              users = {
                users = {
                  ${meta.username} = {
                    isNormalUser = true;
                    description = meta.description;
                    openssh.authorizedKeys.keys = [
                      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAE51+iQSvnNjWATieu+alWv351eNsQmF7jRXUvty/ZH nhan@nixos"
                    ];
                    extraGroups = [
                      "wheel"
                      "networkmanager"
                      "docker"
                      "libvirtd"
                    ];
                  };
                };
              };
            }
            ./nixos/configuration.nix
          ];
        };
      };
    };
}
