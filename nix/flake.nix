# ╭──────────────────────────────────────────────────────────╮
# │ NIX FLAKE                                                │
# ╰──────────────────────────────────────────────────────────╯
{
  description = "NixOS Configuration of Nitestack";

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

    # Hyprland
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    # Hyprland Contrib
    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Tmux SessionX
    tmux-sessionx.url = "github:omerxx/tmux-sessionx";

    # WezTerm
    wezterm.url = "github:wez/wezterm?dir=nix";

    # Zen Browser
    zen-browser.url = "github:MarceColl/zen-browser-flake";
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

      # Supported Systems
      systems = [
        "x86_64-linux"
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
          meta = import ./meta.nix {
            pkgs = import <nixpkgs> {
              config.allowUnfree = true;
            };
          };

          system = "x86_64-linux";
          specialArgs = {
            inherit inputs outputs meta;
          };
          modules = [
            home-manager.nixosModules.home-manager
            ./nixos/base-config.nix
          ];
        in
        {
          ${meta.hostname} = nixpkgs.lib.nixosSystem {
            inherit specialArgs system;
            modules = modules ++ [
              ./nixos/full-config.nix
              {
                nix.settings = {
                  substituters = [ "https://wezterm.cachix.org" ];
                  trusted-public-keys = [ "wezterm.cachix.org-1:kAbhjYUC9qvblTE+s7S+kl5XM1zVa4skO+E/1IDWdH0=" ];
                };
              }
            ];
          };
          ${meta.wslHostname} = nixpkgs.lib.nixosSystem {
            inherit specialArgs system;
            modules =
              [
                nixos-wsl.nixosModules.default
              ]
              ++ modules
              ++ [
                ./nixos/wsl-config.nix
              ];
          };
        };
    };
}
