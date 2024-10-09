# ╭──────────────────────────────────────────────────────────╮
# │ Appearance                                               │
# ╰──────────────────────────────────────────────────────────╯
{
  wayland.windowManager.hyprland.settings = {
    # General
    general = {
      gaps_in = 4; # gaps between windows, also supports css style gaps (top, right, bottom, left -> 5,10,15,20)
      gaps_out = 5; # gaps between windows and monitor edges, also supports css style gaps (top, right, bottom, left -> 5,10,15,20)

      border_size = 1; # size of the border around windows

      "col.active_border" = "rgba(F7DCDE39)"; # border color for the active window
      "col.inactive_border" = "rgba(A58A8D30)"; # border color for inactive windows
    };

    # Decoration
    decoration = {
      rounding = 20; # rounded corners' radius (in layout px)

      drop_shadow = true; # enable drop shadows on windows
      shadow_ignore_window = true; # if true, the shadow will not be rendered behind the window itself, only around it
      shadow_offset = "0 2"; # shadow’s rendering offset
      shadow_range = 20; # Shadow range (“size”) in layout px
      shadow_render_power = 4; # in what power to render the falloff (more power, the faster the falloff) [1 - 4]
      "col.shadow" = "rgba(0000002A)"; # shadow’s color. Alpha dictates shadow’s opacity

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
    };

    windowrulev2 = [ "bordercolor rgba(FFB2BCAA) rgba(FFB2BC77),pinned:1" ];
  };
}
