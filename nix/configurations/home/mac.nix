# ╭──────────────────────────────────────────────────────────╮
# │ macOS Home Manager Configuration                         │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  ...
}:
let
  inherit (flake.inputs) self;
in
{
  # ── Imports ───────────────────────────────────────────────────────────
  imports = [
    self.homeModules.base
    self.homeModules.gui
  ];
}
