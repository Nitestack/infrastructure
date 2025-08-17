{ flake, ... }:
let
  inherit (flake) inputs;
in
{
  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

  services.flatpak.enable = true;
}
