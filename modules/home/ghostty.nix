# ╭──────────────────────────────────────────────────────────╮
# │ Ghostty                                                  │
# ╰──────────────────────────────────────────────────────────╯
{
  meta,
  ...
}:
let
  inherit (meta) font catppuccinFlavor;
in
{
  programs.ghostty = {
    enable = true;
    settings = {
      theme = "Catppuccin ${catppuccinFlavor}";
      font-family = font.nerd.name;
      font-family-italic = "${font.nerd.name} Italic";
      font-size = 11;
      font-feature = "ss01";
      adjust-cell-height = "25%";
      adjust-cursor-height = "25%";
      window-padding-x = 0;
      window-padding-y = 0;
      keybind = "ctrl+enter=unbind";
    };
  };
}
