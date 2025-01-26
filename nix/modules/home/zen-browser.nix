# ╭──────────────────────────────────────────────────────────╮
# │ Browser                                                  │
# ╰──────────────────────────────────────────────────────────╯
{ flake, pkgs, ... }:
let
  inherit (flake) inputs;

  zen-package = inputs.zen-browser.packages.${pkgs.system}.default;
in
{
  home = {
    sessionVariables.BROWSER = "${zen-package}/bin/zen";
    packages = [
      zen-package
    ];
  };
}
