{ meta, ... }:
let
  inherit (meta) font;
in
{
  programs.kitty = {
    enable = true;
    font = {
      name = font.mono.name;
      size = 14;
    };
    shellIntegration.enableZshIntegration = true;
    themeFile = "Catppuccin-Mocha";
  };
}
