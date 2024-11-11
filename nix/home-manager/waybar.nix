# ╭──────────────────────────────────────────────────────────╮
# │ Waybar                                                   │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, meta, ... }:
let
  inherit (meta) font;

  rofi = "${pkgs.rofi-wayland}/bin/rofi";

  catppuccin-css-filename = "mocha";
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
        modules-center = [ "custom/music" ];
        modules-right = [
          "pulseaudio"
          "clock"
          "custom/lock"
          "custom/power"
        ];
        "custom/logo" = {
          format = "";
          tooltip = false;
          on-click = "pkill rofi || ${rofi} -show drun";
        };
        "custom/music" = {
          format = "  {}";
          escape = true;
          interval = 5;
          tooltip = false;
          exec = "playerctl metadata --format='{{ title }}'";
          on-click = "playerctl play-pause";
        };
        clock = {
          timezone = "Europe/Berlin";
          format-alt = " {:%d.%m.%Y}";
          format = "󰥔 {:%H:%M}";
        };
        pulseaudio = {
          # "scroll-step": 1, # %, can be a float
          format = "{icon} {volume}%";
          format-muted = "";
          format-icons = {
            default = [
              ""
              ""
              " "
            ];
          };
          on-click = "pavucontrol";
        };
        "custom/lock" = {
          tooltip = false;
          on-click = "hyprlock";
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
    style = ''
      @import "${catppuccin-css-filename}.css";

      * {
        font-family: "${font.nerd.propoName}";
        font-size: 17px;
        min-height: 0;
      }

      #waybar {
        background: transparent;
        color: @text;
      }

      #custom-logo,
      #window,
      #custom-music,
      #tray,
      #clock,
      #pulseaudio,
      #custom-lock,
      #custom-power {
        background-color: @surface0;
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

      #clock {
        color: @blue;
        border-radius: 0px 1rem 1rem 0px;
        margin-right: 1rem;
      }

      #pulseaudio {
        color: @maroon;
        border-radius: 1rem 0px 0px 1rem;
        margin-left: 1rem;
      }

      #custom-music {
        color: @mauve;
        border-radius: 1rem;
      }

      #custom-lock {
        border-radius: 1rem 0px 0px 1rem;
        color: @lavender;
      }

      #custom-power {
        border-radius: 0px 1rem 1rem 0px;
        color: @red;
        margin-right: 0.5rem;
      }

      /*
      * ── Bottom Bar ────────────────────────────────────────────────────────
      */

      /* Workspaces */
      #workspaces {
        border-radius: 1rem;
        margin: 5px;
        background-color: @surface0;
        margin-left: 0.5rem;
        margin-right: 1rem;
      }
      #workspaces button {
        color: @lavender;
        border-radius: 1rem;
        padding: 0.1rem;
      }
      #workspaces button.active {
        color: @sky;
        border-radius: 1rem;
      }
      #workspaces button:hover {
        color: @sapphire;
        border-radius: 1rem;
      }

      /* Active App */
      #window {
        border-radius: 1rem;
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
  xdg.configFile."waybar/${catppuccin-css-filename}.css".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/waybar/refs/heads/main/themes/${catppuccin-css-filename}.css";
    sha256 = "05yx7v4j9k1s1xanlak7yngqfwvxvylwxc2fhjcfha68rjbhbqx6";
  };
}
