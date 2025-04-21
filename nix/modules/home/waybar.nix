# ╭──────────────────────────────────────────────────────────╮
# │ Waybar                                                   │
# ╰──────────────────────────────────────────────────────────╯
{
  pkgs,
  meta,
  theme,
  ...
}:
let
  inherit (meta) font;

  rofi = "${pkgs.rofi-wayland}/bin/rofi";
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  wpctl = "${pkgs.wireplumber}/bin/wpctl";

  inherit (theme.variables)
    windowBgColor
    windowFgColor
    accentBgColor
    successColor
    warningColor
    warningBgColor
    errorColor
    headerbarBorderColor
    ;
  bgColor = windowBgColor;
  textColor = windowFgColor;
  primaryColor = accentBgColor;
  secondaryColor = headerbarBorderColor;
in
{
  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      target = "hyprland-session.target";
    };
    settings = [
      {
        layer = "top";
        position = "top";
        # Modules
        modules-left = [
          "custom/logo"
          "hyprland/window"
          "mpris"
        ];
        modules-center = [
          "hyprland/workspaces"
        ];
        modules-right = [
          "tray"
          "privacy"
          "wireplumber"
          "clock"
          "group/group-power"
        ];
        "custom/logo" = {
          format = "";
          tooltip = false;
          on-click = "pkill rofi || ${rofi} -show drun";
        };
        "hyprland/window" = {
          format = "{class}";
          separate-outputs = true;
          rewrite = {
            ".blueman-manager-wrapped" = "Bluetooth";
            "com.mitchellh.ghostty" = "Ghostty";
            "org.gnome.Calculator" = "Calculator";
            "org.gnome.Calendar" = "Calendar";
            "org.gnome.clocks" = "Clocks";
            "dconf-editor" = "dconf Editor";
            "vesktop" = "Discord";
            "gnome-disks" = "Disks";
            "evince" = "Document Viewer";
            "com.github.wwmm.easyeffects" = "Easy Effects";
            "org.gnome.FileRoller" = "Archive Manager";
            "org.gnome.Nautilus" = "Files";
            "org.gnome.font-view" = "Fonts";
            "google-chrome" = "Google Chrome";
            "org.gnome.Loupe" = "Image Viewer";
            "org.gnome.Music" = "Music Player";
            "ONLYOFFICE" = "Document Editor";
            ".protonvpn-app-wrapped" = "Proton VPN";
            "qemu" = "QEMU";
            "qt(.*)ct" = "Qt $1 Configuration Tool";
            "rygel-preferences" = "UPnP/DLNA Preferences";
            "Safeeyes" = "Safe Eyes";
            "org.gnome.Settings" = "Settings";
            "signal" = "Signal";
            "spotify" = "Spotify";
            "steam" = "Steam";
            "com.stremio.stremio" = "Stremio";
            "com.gnome.SystemMonitor" = "System Monitor";
            "org.gnome.Todo" = "Todo";
            "totem" = "Video Player";
            ".virt-manager-wrapped" = "Virtual Machine Manager";
            "code" = "Visual Studio Code";
            "wasistlos" = "WhatsApp";
            "org.wezfurlong.wezterm" = "WezTerm";
            "zen" = "Zen Browser";
            "" = "Desktop";
          };
        };
        privacy = {
          icon-size = 16;
          icon-spacing = 12;
        };
        mpris = {
          format = "{player_icon} {dynamic}";
          format-paused = "{status_icon} {dynamic}";
          interval = 1;
          dynamic-len = 60;
          dynamic-order = [
            "title"
            "artist"
          ];
          player-icons = {
            firefox = "";
            spotify = "";
            default = "";
          };
          status-icons = {
            playing = "";
            paused = "";
            stopped = "";
          };
        };
        "hyprland/workspaces" = {
          format = " {icon} ";
          format-icons = {
            active = "";
            default = "";
          };
          on-scroll-up = "${hyprctl} dispatch workspace e+1";
          on-scroll-down = "${hyprctl} dispatch workspace e-1";
        };
        tray = {
          icon-size = 18;
          spacing = 12;
        };
        wireplumber = {
          format = "{icon} {volume}%";
          format-muted = " {volume}%";
          format-icons = [
            ""
            ""
            " "
          ];
          on-click = "${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
        };
        clock = {
          format = "{:%a %b %e %R}";
          tooltip-format = "{calendar}";
          calendar.format = {
            months = "<big><span color='${textColor}' face='${font.sans.name}'><b>{}</b></span></big>";
            days = "<tt><span color='${textColor}'>{}</span></tt>";
            weekdays = "<tt><span color='${errorColor}'>{}</span></tt>";
            today = "<tt><span color='${primaryColor}'><b>{}</b></span></tt>";
          };
          actions = {
            on-click = "shift_reset";
            on-scroll-up = "shift_down";
            on-scroll-down = "shift_up";
          };
        };
        "group/group-power" = {
          orientation = "inherit";
          drawer.transition-left-to-right = false;
          modules = [
            "custom/shutdown"
            "custom/lock"
            "custom/suspend"
            "custom/reboot"
          ];
        };
        "custom/shutdown" = {
          tooltip = false;
          on-click = "systemctl poweroff";
          format = "";
        };
        "custom/lock" = {
          tooltip = false;
          on-click = "loginctl lock-session";
          format = "";
        };
        "custom/suspend" = {
          format = "";
          tooltip = false;
          on-click = "systemctl suspend";
        };
        "custom/reboot" = {
          format = "";
          tooltip = false;
          on-click = "systemctl reboot";
        };
      }
    ];
    style = ''
      * {
        font-family: "${font.sans.name}", "${font.nerd.propoName}";
        font-size: 13pt;
        min-height: 0;
      }

      #waybar {
        border-radius: 1rem;
        background: ${bgColor};
        color: ${textColor};
      }

      /* Common Module Styles */
      .module, #privacy {
        background-color: ${bgColor};
        padding: 0.25rem 0.5rem;
        margin-right: 0.5rem;
        margin-top: 0.1rem;
        margin-bottom: 0.1rem;
      }

      /* Modules with Background */
      #mpris, #workspaces, #tray, #privacy, #group-power:hover {
        border-radius: 1rem;
        background-color: ${secondaryColor};
      }

      /*
      * ── Top Bar ───────────────────────────────────────────────────────────
      */

      /* Logo */
      #custom-logo {
        margin-left: 0.5rem;
        color: #5277C3;
        padding-top: 0.1rem;
        padding-bottom: 0.1rem;
        font-size: 16pt;
      }

      /* Active App */
      #window {
        font-weight: bold;
      }

      /* MPRIS */
      #mpris.spotify {
        color: #1ED760;
      }
      #mpris.firefox {
        color: ${primaryColor};
      }
      #mpris.paused {
        color: ${textColor};
      }

      /* Workspaces */
      #workspaces {
        padding: 0;
      }
      #workspaces button {
        border-radius: 1rem;
        padding: 0.1rem;
      }
      #workspaces button.active {
        color: ${primaryColor};
        border-radius: 1rem;
      }
      #workspaces button:hover {
        color: ${primaryColor};
        border-radius: 1rem;
      }

      /* Privacy */
      #privacy-item.screenshare {
        color: ${warningColor};
      }
      #privacy-item.audio-in {
        color: ${errorColor};
      }

      /* WirePlumber */
      #wireplumber.muted {
        color: ${errorColor};
      }

      /* Power Group */
      #custom-shutdown, #custom-lock, #custom-suspend, #custom-reboot {
        background-color: transparent;
      }
      #custom-lock {
        margin-left: 0.5rem;
        color: ${primaryColor};
      }
      #custom-suspend {
        color: ${warningBgColor};
      }
      #custom-reboot {
        color: ${successColor};
      }
      #custom-shutdown {
        color: ${errorColor};
      }
    '';
  };
}
