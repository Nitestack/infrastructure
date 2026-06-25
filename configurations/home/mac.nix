# ╭──────────────────────────────────────────────────────────╮
# │ macOS Home Manager Configuration                         │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  pkgs,
  ...
}:
let
  inherit (flake.inputs) self;
in
{
  # ── Imports ───────────────────────────────────────────────────────────
  imports = [
    self.homeModules.base
    self.homeModules.gui-only
    self.homeModules.interactive-only
  ];

  home.packages = with pkgs; [
    aldente
    iina
    maccy
    raycast
  ];
}
