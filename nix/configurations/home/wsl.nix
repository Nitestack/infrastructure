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
  ];

  shells.zsh = {
    enable = true;
    enablePerformanceMode = true;
  };
}
