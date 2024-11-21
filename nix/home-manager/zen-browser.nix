# ╭──────────────────────────────────────────────────────────╮
# │ Browser                                                  │
# ╰──────────────────────────────────────────────────────────╯
{ inputs, ... }:
{
  home = {
    # sessionVariables.BROWSER = "firefox";
    packages = [
      inputs.zen-browser.packages.x86_64-linux.generic
    ];
  };
}
