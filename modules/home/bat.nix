# ╭──────────────────────────────────────────────────────────╮
# │ bat                                                      │
# ╰──────────────────────────────────────────────────────────╯
{ flake, meta, ... }:
let
  inherit (flake) inputs;
  inherit (meta) catppuccinFlavor;
  themeName = "Catppuccin ${catppuccinFlavor}";
in
{
  programs.bat = {
    enable = true;
    config.theme = themeName;
    themes.${themeName} = {
      src = inputs.catppuccin-bat;
      file = "themes/${themeName}.tmTheme";
    };
  };
}
