# ╭──────────────────────────────────────────────────────────╮
# │ Window and Workspace Rules                               │
# ╰──────────────────────────────────────────────────────────╯
{ config, ... }:
{
  wayland.windowManager.hyprland.settings =
    let
      floatByTitle = regex: "float on, match:title ^(${regex})(.*)$";
      centerByTitle = regex: "center on, match:title ^(${regex})(.*)$";
      floatByExactTitle = regex: "float on, match:title ^(${regex})$";
      floatByClass = regex: "float on, match:class ^(${regex})(.*)$";
      floatByExactClass = regex: "float on, match:class ^(${regex})$";
      fullscreenByClass = regex: "fullscreen on, match:class ^(${regex})(.*)$";
      fullscreenByExactClass = regex: "fullscreen on, match:class ^(${regex})$";
      noscreenshareByExactClass = regex: "no_screen_share on, match:class ^(${regex})$";

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
        (floatByExactClass "org.gnome.Decibels")
        (floatByExactClass "org.gnome.FileRoller")
        (floatByExactClass "org.gnome.Nautilus")
        (floatByExactClass "org.gnome.SystemMonitor")
        (floatByExactClass "org.gnome.Settings")
        (floatByExactClass "dconf-editor")

        (floatByClass "xdg-desktop-portal")
        (floatByClass ".blueman-manager")

        "dim_around on, match:class ^(gcr-prompter)$"

        # Picture-in-Picture
        (floatByExactTitle "[Pp]icture)[ -]in[ -]([Pp]icture")
        "keep_aspect_ratio on, match:title ^([Pp]icture)[ -]in[ -]([Pp]icture)$"
        "size 25% 25%, match:title ^([Pp]icture)[ -]in[ -]([Pp]icture)$"
        "move (window_w-${toString gap}) (window_w-${toString gap}), match:title ^([Pp]icture)[ -]in[ -]([Pp]icture)$"
        "pin on, match:title ^([Pp]icture)[ -]in[ -]([Pp]icture)$"

        (floatByTitle "Open File")
        (floatByTitle "Open Folder")
        (floatByTitle "File Upload")
        (centerByTitle "File Upload")
        (floatByTitle "Select Folder to Upload")
        (centerByTitle "Select Folder to Upload")
        (floatByTitle "Save As")
        (centerByTitle "Save As")

        "suppress_event maximize, match:class .*"

        (noscreenshareByExactClass "Bitwarden")
        (noscreenshareByExactClass "io.ente.auth")
        "no_screen_share on, match:class ^(zen)$, match:title ^Extension: .* - Bitwarden .*"
        "no_screen_share on, match:class ^(zen)$, match:title ^Ente Auth .*"

        # Game Settings
        "immediate on, match:class ^(steam_app_)(.*)$"
        "immediate on, match:class ^(Ryujinx)$, match:title ^Ryujinx .* - .*"
        "immediate on, match:class ^(org.vinegarhq.Sober)$"
        "immediate on, match:class ^(Minecraft)(.*)$"

        (fullscreenByClass "steam_app_")
        (fullscreenByExactClass "Ryujinx")
        (fullscreenByExactClass "org.vinegarhq.Sober")
        (fullscreenByClass "Minecraft")

        "idle_inhibit focus, match:class ^(Ryujinx)$"
      ];
    };
}
