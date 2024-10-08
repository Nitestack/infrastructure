# ╭──────────────────────────────────────────────────────────╮
# │ Window and Workspace Rules                               │
# ╰──────────────────────────────────────────────────────────╯
{
  wayland.windowManager.hyprland.settings = {
    windowrule =
      let
        f = regex: "float, ^(${regex})$";
      in
      [
        "opacity 0.89 override 0.89 override, .*" # Transparency

        # Floating windows
        (f "confirm")
        (f "file_progress")
        (f "dialog")

        (f "org.gnome.Calculator")
        (f "org.gnome.Nautilus")
        (f "org.gnome.SystemMonitor")
        (f "nm-connection-editor")
        (f "org.gnome.Settings")
        (f "org.gnome.design.Palette")

        (f "Color Picker")
        (f "dconf-editor")

        (f "com.github.GradienceTeam.Gradience")

        (f "pavucontrol")
        (f "nm-connection-editor")
        (f "xdg-desktop-portal")
        (f "xdg-desktop-portal-gnome")

        "immediate,.*\.exe" # Tearing
      ];

    windowrulev2 = [
      "suppressevent maximize, class:.*"
      "immediate,class:(steam_app)" # Tearing
    ];
  };
}
