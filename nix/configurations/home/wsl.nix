# ╭──────────────────────────────────────────────────────────╮
# │ NixOS WSL Home Manager Configuration                     │
# ╰──────────────────────────────────────────────────────────╯
{ flake, ... }:
let
  inherit (flake.inputs) self;
in
{
  # ── Imports ───────────────────────────────────────────────────────────
  imports = [
    self.homeModules.base
    self.homeModules.linux-only
  ];

  programs.zathura.enable = true;
}
