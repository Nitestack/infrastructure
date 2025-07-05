# ╭──────────────────────────────────────────────────────────╮
# │ Window and Workspace Rules                               │
# ╰──────────────────────────────────────────────────────────╯
{ config, meta, ... }:
let
  inherit (meta) monitors;
in
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
        (floatByExactClass "waypaper")

        (floatByClass "xdg-desktop-portal")
        (floatByClass "xdg-desktop-portal-gnome")
        (floatByClass ".blueman-manager")

        "dimaround, class:^(gcr-prompter)$"

        # Picture-in-Picture
        (floatByExactTitle "[Pp]icture)[ -]in[ -]([Pp]icture")
        "keepaspectratio, title:^([Pp]icture)[ -]in[ -]([Pp]icture)$"
        "size 25% 25%, title:^([Pp]icture)[ -]in[ -]([Pp]icture)$"
        "move 100%-w-${toString gap} 100%-w-${toString gap}, title:^([Pp]icture)[ -]in[ -]([Pp]icture)$"
        "pin, title:^([Pp]icture)[ -]in[ -]([Pp]icture)$"

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
      workspace = (
        builtins.concatLists (
          builtins.genList (
            i:
            let
              wsNo = i + 1;
              isMultipleMonitors = (builtins.length monitors) > 1;
              monitor = (builtins.elemAt monitors (if isMultipleMonitors && wsNo > 5 then 1 else 0)).name;
            in
            [
              "${toString wsNo}, monitor:${monitor}, default:${
                if wsNo == 1 || (isMultipleMonitors && wsNo == 6) then "true" else "false"
              }"
            ]
          ) 10
        )
      );
    };
}
