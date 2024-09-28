# ╭──────────────────────────────────────────────────────────╮
# │ kitty                                                    │
# ╰──────────────────────────────────────────────────────────╯
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
    settings = {
      symbol_map = "U+1FBF0,U+1FBF1,U+1FBF2,U+1FBF3,U+1FBF4,U+1FBF5,U+1FBF6,U+1FBF7,U+1FBF8,U+1FBF9 Iosevka Nerd Font Mono";
    };
  };
}
