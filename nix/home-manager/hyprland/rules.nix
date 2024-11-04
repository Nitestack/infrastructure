# ╭──────────────────────────────────────────────────────────╮
# │ Window and Workspace Rules                               │
# ╰──────────────────────────────────────────────────────────╯
{
  wayland.windowManager.hyprland.settings = {
    windowrule =
      let
        float = regex: "float, ^(${regex})$";
        floatAction = regex: "float, title:^(${regex})(.*)$";
      in
      [
        "opacity 0.89 override 0.89 override, .*" # Transparency

        # Floating windows
        (float "confirm")
        (float "file_progress")
        (float "dialog")

        (float "org.gnome.Calculator")
        (float "org.gnome.Nautilus")
        (float "org.gnome.SystemMonitor")
        (float "nm-connection-editor")
        (float "org.gnome.Settings")

        (float "Color Picker")
        (float "dconf-editor")

        (float "pavucontrol")
        (float "nm-connection-editor")
        (float "xdg-desktop-portal")
        (float "xdg-desktop-portal-gnome")

        # Actions
        (floatAction "Open Files")
        (floatAction "Open Folder")
        (floatAction "Save As")

        "immediate,.*\.exe" # Tearing
      ];

    windowrulev2 = [
      "suppressevent maximize, class:.*"
      "immediate,class:(steam_app)" # Tearing
    ];
  };
}
