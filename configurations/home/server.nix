# ╭──────────────────────────────────────────────────────────╮
# │ NixOS Server Home Manager Configuration                  │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  lib,
  osConfig,
  ...
}:
let
  inherit (flake.inputs) self;
in
{
  # ── Imports ───────────────────────────────────────────────────────────
  imports = [
    self.homeModules.base
    self.homeModules.bare-metal-only
  ];

  home.shellAliases.beet = lib.mkIf (osConfig.homelab.apps.beets.services.main.enable) "docker exec -it beets beet";
}
