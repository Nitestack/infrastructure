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
          "cpu"
          "memory"
          "disk"
        ];
        modules-center = [ "mpris" ];
        modules-right = [
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
        cpu = {
          format = " {usage}%";
        };
        memory = {
          format = " {percentage}%";
          tooltip-format = "{used:0.1f}/{total:0.1f}GiB RAM used\n{swapUsed:0.1f}/{swapTotal}GiB swap used";
        };
        disk = {
          format = " {percentage_used}%";
          unit = "GiB";
          tooltip-format = "{specific_used:0.1f}/{specific_total:0.1f}GiB used";
        };
        mpris = {
          format = "{player_icon} {dynamic}";
          format-paused = "{status_icon} <i>{dynamic}</i>";
          interval = 1;
          dynamic-order = [
            "title"
            "artist"
            "position"
            "length"
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
        clock = {
          timezone = "Europe/Berlin";
          format-alt = " {:%d.%m.%Y}";
          format = "󰥔 {:%H:%M}";
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
      {
        layer = "top";
        position = "bottom";
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [
          "privacy"
          "hyprland/window"
        ];
        modules-right = [
          "tray"
          "wlr/taskbar"
        ];
        "hyprland/workspaces" = {
          format = " {icon} ";
          format-icons = {
            active = "";
            default = "";
          };
          on-scroll-up = "${hyprctl} dispatch workspace e+1";
          on-scroll-down = "${hyprctl} dispatch workspace e-1";
        };
        privacy = {
          icon-spacing = 16;
        };
        "hyprland/window" = {
          icon = true;
          icon-size = 21;
          separate-outputs = true;
          rewrite = {
            "(.*) — Zen Browser" = "$1";
            "(.*) - Google Chrome" = "$1";
            "Spotify Free" = "Spotify";
            "Spotify Premium" = "Spotify";
            "web.whatsapp.com" = "WhatsApp";
          };
        };
        "wlr/taskbar" = {
          icon-size = 21;
          on-click = "activate";
          on-click-middle = "close";
          tooltip-format = "{name}";
        };
        tray = {
          icon-size = 21;
          spacing = 16;
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
          warningBgColor
          errorColor
          ;
        inherit (theme.palette)
          blue
          yellow
          ;
        bgColor = windowBgColor;
        textColor = windowFgColor;
        primaryColor = accentBgColor;
      in
      ''
        * {
          font-family: "${font.nerd.propoName}";
          font-size: 17px;
          min-height: 0;
        }

        #waybar {
          background: transparent;
          color: ${textColor};
        }

        #custom-logo,
        #window,
        #privacy,
        #workspaces,
        #mpris,
        #tray,
        #clock,
        #wireplumber,
        #custom-lock,
        #custom-power,
        #cpu,
        #memory,
        #taskbar,
        #disk {
          background-color: ${bgColor};
          padding: 0.5rem 1rem;
          margin: 5px 0;
        }

        /*
        * ── Top Bar ───────────────────────────────────────────────────────────
        */

        /* Logo */
        #custom-logo {
          color: #5277C3;
          border-radius: 1rem;
          margin-left: 0.5rem;
        }

        /* System Stats */
        #cpu {
          margin-left: 1rem;
          border-radius: 1rem 0px 0px 1rem;
          color: ${warningColor};
        }
        #memory {
          color: ${blue."2"};
        }
        #disk {
          border-radius: 0px 1rem 1rem 0px;
          color: ${yellow."3"};
        }

        /* MPRIS */
        #mpris {
          font-weight: bold;
          border-radius: 1rem;
        }
        #mpris.spotify {
          color: #1ED760;
        }
        #mpris.firefox {
          color: ${primaryColor};
        }
        #mpris.paused {
          color: ${warningBgColor};
        }

        /* WirePlumber */
        #wireplumber {
          border-radius: 1rem 0px 0px 1rem;
          margin-left: 1rem;
        }
        #wireplumber.muted {
          color: ${errorColor};
        }

        #clock {
          border-radius: 0px 1rem 1rem 0px;
          margin-right: 1rem;
        }

        #custom-lock {
          border-radius: 1rem 0px 0px 1rem;
          color: ${warningBgColor};
        }

        /* Power Button */
        #custom-power {
          border-radius: 0px 1rem 1rem 0px;
          color: ${errorColor};
          margin-right: 0.5rem;
        }

        /*
        * ── Bottom Bar ────────────────────────────────────────────────────────
        */

        /* Workspaces */
        #workspaces {
          border-radius: 1rem;
          margin-left: 0.5rem;
          padding: 0;
          margin-right: 1rem;
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
        #privacy {
          margin-left: 1rem;
          border-radius: 1rem;
        }
        #privacy-item.screenshare {
          color: ${warningColor};
        }
        #privacy-item.audio-in {
          color: ${errorColor};
        }

        /* Active App */
        #window {
          border-radius: 1rem;
          font-weight: bold;
        }

        window#waybar.empty #window {
          background-color: transparent;
        }

        /* Tray */
        #tray {
          margin-left: 1rem;
          border-radius: 1rem;
        }

        /* Taskbar */
        #taskbar {
          margin-left: 1rem;
          border-radius: 1rem;
          margin-right: 0.5rem;
          padding: 0;
          padding-left: 0.5rem;
          padding-right: 0.5rem;
        }
        #taskbar button {
          padding: 0.5rem;
        }
        #taskbar button.active {
          padding-bottom: calc(0.5rem - 2px);
          border-bottom: 2px solid ${primaryColor};
          border-bottom-left-radius: 0;
          border-bottom-right-radius: 0;
        }
        #taskbar button.active:hover {
          border-radius: inherit;
        }
      '';
  };
}
