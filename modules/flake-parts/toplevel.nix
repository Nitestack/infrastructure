# ╭──────────────────────────────────────────────────────────╮
# │ Top-level                                                │
# ╰──────────────────────────────────────────────────────────╯
{ inputs, ... }:
{
  imports = [
    inputs.nixos-unified.flakeModules.default
    inputs.nixos-unified.flakeModules.autoWire
  ];
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      formatter = pkgs.nixfmt;
    };
}
