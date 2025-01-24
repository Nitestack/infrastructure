# ╭──────────────────────────────────────────────────────────╮
# │ Nix Hosts                                                │
# ╰──────────────────────────────────────────────────────────╯
{
  self,
  inputs,
  ...
}:
{
  flake.nixosConfigurations =
    let
      inherit (inputs.nixpkgs.lib) nixosSystem;

      meta = import ../meta.nix {
        pkgs = import inputs.nixpkgs {
          config.allowUnfree = true;
        };
      };
      theme = builtins.fromJSON (builtins.readFile ../theme.json);
      specialArgs = {
        inherit
          self
          inputs
          meta
          theme
          ;
      };
      modules = [
        inputs.home-manager.nixosModules.home-manager
        ./base
        {
          home-manager.extraSpecialArgs = specialArgs;
        }
      ];
    in
    {
      ${meta.hostname} = nixosSystem {
        inherit specialArgs;
        modules = modules ++ [
          ./desktop
          {
            nix.settings = {
              substituters = [ "https://wezterm.cachix.org" ];
              trusted-public-keys = [ "wezterm.cachix.org-1:kAbhjYUC9qvblTE+s7S+kl5XM1zVa4skO+E/1IDWdH0=" ];
            };
          }
        ];
      };
      ${meta.wslHostname} = nixosSystem {
        inherit specialArgs;
        modules =
          [
            inputs.nixos-wsl.nixosModules.default
          ]
          ++ modules
          ++ [
            ./wsl
          ];
      };
    };
}
