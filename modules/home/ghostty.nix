# ╭──────────────────────────────────────────────────────────╮
# │ Ghostty                                                  │
# ╰──────────────────────────────────────────────────────────╯
{
  meta,
  pkgs,
  lib,
  ...
}:
let
  inherit (meta) font;
in
{
  programs.ghostty = {
    enable = true;
    package = lib.mkIf pkgs.stdenv.isDarwin null; # NOTE: `ghostty` package is broken on macOS
    settings = {
      theme = "catppuccin-mocha";
      font-family = font.nerd.name;
      font-family-italic = "${font.nerd.name} Italic";
      font-feature = "ss01";
      adjust-cell-height = "50%";
      adjust-cursor-height = "50%";
      window-padding-x = 0;
      window-padding-y = 0;
      command = "${pkgs.nushell}/bin/nu";
    };
  };
}
