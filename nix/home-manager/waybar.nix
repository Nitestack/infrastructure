# ╭──────────────────────────────────────────────────────────╮
# │ Waybar                                                   │
# ╰──────────────────────────────────────────────────────────╯
{
  inputs,
  pkgs,
  meta,
  theme,
  ...
}:
let
  inherit (meta) font;

  rofi = "${pkgs.rofi-wayland}/bin/rofi";
  hyprlock = "${pkgs.hyprlock}/bin/hyprlock";
  hyprctl = "${inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland}/bin/hyprctl";
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
        modules-left = [ "custom/logo" ];
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
          on-click = "wlogout &";
          format = "";
        };
      }
      {
        layer = "top";
        position = "bottom";
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "hyprland/window" ];
        modules-right = [ "tray" ];
        "hyprland/workspaces" = {
          format = " {icon} ";
          format-icons = {
            active = "";
            default = "";
          };
          on-scroll-up = "${hyprctl} dispatch workspace e+1";
          on-scroll-down = "${hyprctl} dispatch workspace e-1";
        };
        "hyprland/window" = {
          icon = true;
          icon-size = 21;
          separate-outputs = true;
          rewrite = {
            "(.*) — Zen Browser" = "$1";
            "(.*) - Google Chrome" = "$1";
            "Spotify Free" = "Spotify";
            "WebCord - (.*)" = "$1";
            "web.whatsapp.com" = "WhatsApp";
          };
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
          warningBgColor
          errorColor
          ;
        inherit (theme.palette)
          red
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
        #workspaces,
        #mpris,
        #tray,
        #clock,
        #wireplumber,
        #custom-lock,
        #custom-power {
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
          color: ${red."3"};
        }

        #clock {
          border-radius: 0px 1rem 1rem 0px;
          margin-right: 1rem;
        }

        #custom-lock {
          border-radius: 1rem 0px 0px 1rem;
          color: ${warningBgColor};
        }

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
          margin-right: 1rem;
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
          margin-right: 0.5rem;
          border-radius: 1rem;
        }
      '';
  };
}
