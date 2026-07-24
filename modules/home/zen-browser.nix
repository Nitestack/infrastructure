# ╭──────────────────────────────────────────────────────────╮
# │ Browser                                                  │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  pkgs,
  lib,
  ...
}:
let
  inherit (flake) inputs;

  zen-package = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  home = {
    sessionVariables.BROWSER = lib.getExe zen-package;
    packages = [
      zen-package
    ];
  };
}
