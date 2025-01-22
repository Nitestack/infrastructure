# ╭──────────────────────────────────────────────────────────╮
# │ Browser                                                  │
# ╰──────────────────────────────────────────────────────────╯
{ inputs, pkgs, ... }:
let
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
