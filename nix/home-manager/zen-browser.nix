# ╭──────────────────────────────────────────────────────────╮
# │ Browser                                                  │
# ╰──────────────────────────────────────────────────────────╯
{ inputs, ... }:
let
  zen-package = inputs.zen-browser.packages.x86_64-linux.default;
in
{
  home = {
    sessionVariables.BROWSER = "${zen-package}/bin/zen";
    packages = [
      zen-package
    ];
  };
}
