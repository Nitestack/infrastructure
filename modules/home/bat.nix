# ╭──────────────────────────────────────────────────────────╮
# │ bat                                                      │
# ╰──────────────────────────────────────────────────────────╯
{ flake, ... }:
let
  inherit (flake) inputs;
in
{
  programs.bat = {
    enable = true;
    config.theme = "Catppuccin Mocha";
    themes."Catppuccin Mocha" = {
      src = inputs.catppuccin-bat;
      file = "themes/Catppuccin Mocha.tmTheme";
    };
  };
}
