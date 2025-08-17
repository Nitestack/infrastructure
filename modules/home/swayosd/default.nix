# ╭──────────────────────────────────────────────────────────╮
# │ SwayOSD                                                  │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, meta, ... }:
let
  inherit (meta) font;

  styles = pkgs.lib.scss.compileToCss {
    src = ./style.scss;
    variables = {
      font-nerd-propo = font.nerd.propoName;
    };
  };
in
{
  services.swayosd = {
    enable = true;
    stylePath = styles;
  };
}
