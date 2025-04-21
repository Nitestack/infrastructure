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
  hyprlock = "${pkgs.hyprlock}/bin/hyprlock";
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  wlogout = "${pkgs.wlogout}/bin/wlogout";
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
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
          "custom/lock"
          "custom/power"
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
          timezone = "Europe/Berlin";
          format-alt = " {:%d.%m.%Y}";
          format = "󰥔 {:%H:%M}";
        };
        "custom/lock" = {
          tooltip = false;
          on-click = hyprlock;
          format = "";
        };
        "custom/power" = {
          tooltip = false;
          on-click = "${wlogout} &";
          format = "";
        };
      }
    ];
    style =
      let
        inherit (theme.variables)
          windowBgColor
          windowFgColor
          accentBgColor
          warningColor
          errorColor
          headerbarBorderColor
          ;
        bgColor = windowBgColor;
        textColor = windowFgColor;
        primaryColor = accentBgColor;
        secondaryColor = headerbarBorderColor;
      in
      ''
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

        .module, #privacy {
          background-color: ${bgColor};
          padding: 0.25rem 0.5rem;
          margin-right: 0.5rem;
          margin-top: 0.1rem;
          margin-bottom: 0.1rem;
        }

        /*
        * ── Top Bar ───────────────────────────────────────────────────────────
        */

        /* Logo */
        #custom-logo {
          margin-left: 0.5rem;
          color: #5277C3;
        }

        /* Active App */
        #window {
          font-weight: bold;
        }

        /* MPRIS */
        #mpris {
          border-radius: 1rem;
          background-color: ${secondaryColor};
        }
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
          border-radius: 1rem;
          padding: 0;
          background-color: ${secondaryColor};
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

        /* Tray */
        #tray {
          border-radius: 1rem;
          background-color: ${secondaryColor};
        }

        /* Privacy */
        #privacy {
          border-radius: 1rem;
          background-color: ${secondaryColor};
        }
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

        /* Power Button */
        #custom-power {
          color: ${errorColor};
        }
      '';
  };
}
