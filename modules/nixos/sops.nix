# ╭──────────────────────────────────────────────────────────╮
# │ NixOS Secrets (sops)                                     │
# ╰──────────────────────────────────────────────────────────╯
{ flake, ... }:
let
  inherit (flake) inputs;
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
    ../shared/system/sops.nix
  ];
}
