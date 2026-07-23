# ╭──────────────────────────────────────────────────────────╮
# │ Darwin Secrets (sops)                                    │
# ╰──────────────────────────────────────────────────────────╯
{ flake, ... }:
let
  inherit (flake) inputs;
in
{
  imports = [
    inputs.sops-nix.darwinModules.sops
    ../shared/system/sops.nix
  ];
}
