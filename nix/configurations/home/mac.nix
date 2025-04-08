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
  ];

  home.packages = with pkgs; [
    alt-tab-macos
    aldente
    iina
    maccy
    raycast
    rectangle
  ];
}
