# ╭──────────────────────────────────────────────────────────╮
# │ Ghostty                                                  │
# ╰──────────────────────────────────────────────────────────╯
{ meta, pkgs, ... }:
let
  inherit (meta) font;
in
{
  programs.ghostty = {
    enable = true;
    settings = {
      theme = "catppuccin-mocha";
      font-family = [
        font.nerd.name
        font.emoji.name
        "Symbols Nerd Font"
      ];
      font-family-italic = font.nerd.italic.name;
      font-size = 14;
      adjust-cell-height = "50%";
      adjust-cursor-height = "50%";
      window-padding-x = 0;
      window-padding-y = 0;
      command = "${pkgs.nushell}/bin/nu";
    };
  };
}
