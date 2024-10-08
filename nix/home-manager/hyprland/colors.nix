# ╭──────────────────────────────────────────────────────────╮
# │ Colors                                                   │
# ╰──────────────────────────────────────────────────────────╯
{
  wayland.windowManager.hyprland.settings = {
    general = {
      "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg"; # border color for the active window
      "col.inactive_border" = "rgba(595959aa)"; # border color for inactive windows
    };

    decoration."col.shadow" = "0x66000000"; # shadow’s color. Alpha dictates shadow’s opacity

    windowrulev2 = [ "bordercolor rgba(FFB2BCAA) rgba(FFB2BC77),pinned:1" ];
  };
}
