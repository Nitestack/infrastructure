# ╭──────────────────────────────────────────────────────────╮
# │ Appearance                                               │
# ╰──────────────────────────────────────────────────────────╯
{ theme, ... }:
let
  inherit (theme.variables) accentBgColor;
  rgba = color: builtins.replaceStrings [ "#" ] [ "" ] "rgba(${color}ff)";
in
{
  wayland.windowManager.hyprland.settings = {
    # General
    general = {
      gaps_in = 4; # gaps between windows, also supports css style gaps (top, right, bottom, left -> 5,10,15,20)
      gaps_out = 5; # gaps between windows and monitor edges, also supports css style gaps (top, right, bottom, left -> 5,10,15,20)

      border_size = 2; # size of the border around windows

      "col.active_border" = rgba accentBgColor; # border color for the active window
      "col.inactive_border" = "rgba(A58A8D30)"; # border color for inactive windows
    };

    # Decoration
    decoration = {
      rounding = 16; # rounded corners' radius (in layout px)

      # Blur
      blur = {
        enabled = true;
        xray = true;
        special = false;
        new_optimizations = true;
        size = 14;
        passes = 4;
        brightness = 1;
        noise = 1.0e-2;
        contrast = 1;
        popups = true;
        popups_ignorealpha = 0.6;
      };

      # Shadow
      shadow = {
        enabled = true;
        range = 20; # Shadow range (“size”) in layout px
        offset = "0 2"; # shadow’s rendering offset
        render_power = 4; # in what power to render the falloff (more power, the faster the falloff) [1 - 4]
        color = "rgba(0000002A)"; # shadow’s color. Alpha dictates shadow’s opacity
      };
    };
  };
}
