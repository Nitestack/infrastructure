# ╭──────────────────────────────────────────────────────────╮
# │ Window and Workspace Rules                               │
# ╰──────────────────────────────────────────────────────────╯
{ config, ... }:
{
  wayland.windowManager.hyprland.settings =
    let
      floatByTitle = regex: "float, title:^(${regex})(.*)$";
      centerByTitle = regex: "center, title:^(${regex})(.*)$";
      floatByExactTitle = regex: "float, title:^(${regex})$";
      floatByClass = regex: "float, class:^(${regex})(.*)$";
      floatByExactClass = regex: "float, class:^(${regex})$";

      gap =
        config.wayland.windowManager.hyprland.settings.general.gaps_out
        + config.wayland.windowManager.hyprland.settings.general.border_size;
    in
    {
      windowrulev2 = [
        (floatByExactClass "confirm")
        (floatByExactClass "file_progress")
        (floatByExactClass "dialog")
        (floatByExactClass "org.gnome.Calculator")
        (floatByExactClass "org.gnome.FileRoller")
        (floatByExactClass "org.gnome.Nautilus")
        (floatByExactClass "org.gnome.SystemMonitor")
        (floatByExactClass "org.gnome.Settings")
        (floatByExactClass "dconf-editor")
        (floatByExactClass "steam")

        (floatByClass "xdg-desktop-portal")
        (floatByClass "xdg-desktop-portal-gnome")
        (floatByClass ".blueman-manager")
        (floatByClass "org.raspberrypi")

        (floatByExactTitle "btop")

        # Picture-in-Picture
        (floatByExactTitle "Picture-in-Picture")
        "keepaspectratio, title:^(Picture-in-Picture)$"
        "size 25% 25%, title:^(Picture-in-Picture)$"
        "move 100%-w-${toString gap} 100%-w-${toString gap}, title:^(Picture-in-Picture)$"
        "pin, title:^(Picture-in-Picture)$"

        (floatByTitle "Open File")
        (floatByTitle "Open Folder")
        (floatByTitle "File Upload")
        (centerByTitle "File Upload")
        (floatByTitle "Select Folder to Upload")
        (centerByTitle "Select Folder to Upload")
        (floatByTitle "Save As")
        (centerByTitle "Save As")

        "suppressevent maximize, class:.*"
        "immediate,class:(steam_app)" # Tearing
      ];
    };
}
