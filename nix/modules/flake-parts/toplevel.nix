# ╭──────────────────────────────────────────────────────────╮
# │ Top-level                                                │
# ╰──────────────────────────────────────────────────────────╯
{ self, inputs, ... }:
{
  imports = [
    inputs.nixos-unified.flakeModules.default
    inputs.nixos-unified.flakeModules.autoWire
  ];
  perSystem =
    {
      pkgs,
      system,
      lib,
      ...
    }:
    {
      formatter = pkgs.nixfmt-rfc-style;
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = lib.attrValues self.overlays;
        config.allowUnfree = true;
      };
    };
}
