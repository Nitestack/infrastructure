# ╭──────────────────────────────────────────────────────────╮
# │ Window and Workspace Rules                               │
# ╰──────────────────────────────────────────────────────────╯
{ config, ... }:
{
  wayland.windowManager.hyprland.settings =
    let
      floatByTitle = regex: {
        match.title = "^(${regex})(.*)$";
        float = true;
      };
      centerByTitle = regex: {
        match.title = "^(${regex})(.*)$";
        center = true;
      };
      floatByExactTitle = regex: {
        match.title = "^(${regex})$";
        float = true;
      };
      floatByClass = regex: {
        match.class = "^(${regex})(.*)$";
        float = true;
      };
      floatByExactClass = regex: {
        match.class = "^(${regex})$";
        float = true;
      };
      fullscreenByClass = regex: {
        match.class = "^(${regex})(.*)$";
        fullscreen = true;
      };
      fullscreenByExactClass = regex: {
        match.class = "^(${regex})$";
        fullscreen = true;
      };
      noscreenshareByExactClass = regex: {
        match.class = "^(${regex})$";
        no_screen_share = true;
      };

      gap =
        config.wayland.windowManager.hyprland.settings.config.general.gaps_out
        + config.wayland.windowManager.hyprland.settings.config.general.border_size;
      pipTitleRegex = "([Pp]icture)[ -]in[ -]([Pp]icture)";
    in
    {
      window_rule = [
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

        {
          match.class = "^(gcr-prompter)$";
          dim_around = true;
        }

        # Picture-in-Picture
        (floatByExactTitle pipTitleRegex)
        {
          match.title = "^${pipTitleRegex}$";
          keep_aspect_ratio = true;
        }
        {
          match.title = "^${pipTitleRegex}$";
          size = [
            "25%"
            "25%"
          ];
        }
        {
          match.title = "^${pipTitleRegex}$";
          move = [
            "window_w-${toString gap}"
            "window_h-${toString gap}"
          ];
        }
        {
          match.title = "^${pipTitleRegex}$";
          pin = true;
        }

        (floatByTitle "Open File")
        (floatByTitle "Open Folder")
        (floatByTitle "File Upload")
        (centerByTitle "File Upload")
        (floatByTitle "Select Folder to Upload")
        (centerByTitle "Select Folder to Upload")
        (floatByTitle "Save As")
        (centerByTitle "Save As")

        {
          match.class = ".*";
          suppress_event = "maximize";
        }

        (noscreenshareByExactClass "Bitwarden")
        (noscreenshareByExactClass "io.ente.auth")
        {
          match = {
            class = "^(zen)$";
            title = "^Extension: .* - Bitwarden .*";
          };
          no_screen_share = true;
        }
        {
          match = {
            class = "^(zen)$";
            title = "^Ente Auth .*";
          };
          no_screen_share = true;
        }

        # Game Settings
        {
          match.class = "^(steam_app_)(.*)$";
          immediate = true;
        }
        {
          match = {
            class = "^(Ryujinx)$";
            title = "^Ryujinx .* - .*";
          };
          immediate = true;
        }
        {
          match.class = "^(org.vinegarhq.Sober)$";
          immediate = true;
        }
        {
          match.class = "^(Minecraft)(.*)$";
          immediate = true;
        }

        (fullscreenByClass "steam_app_")
        (fullscreenByExactClass "Ryujinx")
        (fullscreenByExactClass "org.vinegarhq.Sober")
        (fullscreenByClass "Minecraft")

        {
          match.class = "^(Ryujinx)$";
          idle_inhibit = "focus";
        }
      ];
    };
}
