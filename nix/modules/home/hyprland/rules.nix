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
      fullscreenByClass = regex: "fullscreen, class:^(${regex})(.*)$";
      fullscreenByExactClass = regex: "fullscreen, class:^(${regex})$";
      noscreenshareByExactClass = regex: "noscreenshare, class:^(${regex})$";

      gap =
        config.wayland.windowManager.hyprland.settings.general.gaps_out
        + config.wayland.windowManager.hyprland.settings.general.border_size;
    in
    {
      windowrule = [
        (floatByExactClass "confirm")
        (floatByExactClass "file_progress")
        (floatByExactClass "dialog")
        (floatByExactClass "org.gnome.Calculator")
        (floatByExactClass "org.gnome.FileRoller")
        (floatByExactClass "org.gnome.Nautilus")
        (floatByExactClass "org.gnome.SystemMonitor")
        (floatByExactClass "org.gnome.Settings")
        (floatByExactClass "dconf-editor")

        (floatByClass "xdg-desktop-portal")
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

        (noscreenshareByExactClass "Bitwarden")
        (noscreenshareByExactClass "io.ente.auth")
        "noscreenshare, class:^(zen)$, title:^Extension: .* - Bitwarden .*"
        "noscreenshare, class:^(zen)$, title:^Ente Auth .*"

        # Game Settings
        "immediate, class:^(steam_app_)(.*)$"
        "immediate, class:^(Ryujinx)$, title:^Ryujinx .* - .*"
        "immediate, class:^(org.vinegarhq.Sober)$"
        "immediate, class:^(Minecraft)(.*)$"

        (fullscreenByClass "steam_app_")
        (fullscreenByExactClass "Ryujinx")
        (fullscreenByExactClass "org.vinegarhq.Sober")
        (fullscreenByClass "Minecraft")

        "idleinhibit focus, class:^(Ryujinx)$"
      ];
    };
}
