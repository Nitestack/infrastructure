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

  blueman-manager = "${pkgs.blueman}/bin/blueman-manager";
  rofi = "${pkgs.rofi-wayland}/bin/rofi";
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
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
  home.packages = with pkgs; [ socat ];
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings =
      let
        spacing = 12;
      in
      [
        {
          layer = "top";
          position = "top";
          # Modules
          modules-left = [
            "custom/logo"
            "custom/window"
            "custom/mpris"
          ];
          modules-center = [
            "hyprland/workspaces"
          ];
          modules-right = [
            "tray"
            "privacy"
            "bluetooth"
            "group/group-network"
            "wireplumber"
            "clock"
            "group/group-power"
          ];
          "custom/logo" = {
            format = "<span color='#5277C3'></span>";
            tooltip = false;
            on-click = "pkill rofi || ${rofi} -show drun";
          };
          "custom/window" = {
            exec = "nu ${./app-name.nu}";
            return-type = "json";
            hide-empty-text = true;
            format = "{text}";
            tooltip-format = "{alt}";
          };
          privacy = {
            icon-spacing = spacing;
            icon-size = 16;
          };
          "custom/mpris" = {
            exec = "python3 -u ${./mpris.py}";
            return-type = "json";
            hide-empty-text = true;
            format = "<tt>{text}</tt>";
            on-click = "${playerctl} play-pause";
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
            inherit spacing;
            icon-size = 18;
          };
          bluetooth = {
            format-connected = "<span color='${primaryColor}'>󰂱</span>";
            format-on = "<span color='${primaryColor}'>󰂰</span>";
            format-off = "<span color='${warningBgColor}'>󰂯</span>";
            format-disabled = "<span color='${errorColor}'>󰂲</span>";
            format-no-controller = "";
            tooltip-format-connected = "Connected Devices:\n{device_enumerate}";
            tooltip-format-enumerate-connected = "• {device_alias}";
            tooltip-format-on = "Ready";
            tooltip-format-off = "Idle";
            tooltip-format-disabled = "Disabled";
            on-click = blueman-manager;
          };
          "group/group-network" = {
            orientation = "inherit";
            drawer.click-to-reveal = true;
            modules = [
              "network"
              "network#download"
              "network#upload"
            ];
          };
          network = {
            format-ethernet = "󰈀";
            format-wifi = "󰖩";
            format-disconnected = "<span color='${errorColor}'>󰖪</span>";
            tooltip-format = "<tt>{ipaddr}</tt>";
            tooltip-format-wifi = "<b>{essid}</b> ({frequency} GHz)\n<tt>{gwaddr}</tt>";
            tooltip-format-disconnected = "Disconnected";
          };
          "network#download" = {
            interval = 1;
            format = "󰇚 {bandwidthDownBits}";
            tooltip-format = "Receiving";
          };
          "network#upload" = {
            interval = 1;
            format = "󰕒 {bandwidthUpBits}";
            tooltip-format = "Sending";
          };
          wireplumber = {
            format = "{icon} {volume}%";
            format-muted = "<span color='${errorColor}'> {volume}%</span>";
            format-icons = [
              ""
              ""
              " "
            ];
            on-click = "${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
          };
          clock = {
            format = "{:%a %b %d %R}";
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
            format = "<span color='${errorColor}'></span>";
          };
          "custom/lock" = {
            tooltip = false;
            on-click = "loginctl lock-session";
            format = "<span color='${primaryColor}'></span>";
          };
          "custom/suspend" = {
            tooltip = false;
            on-click = "systemctl suspend";
            format = "<span color='${warningBgColor}'></span>";
          };
          "custom/reboot" = {
            tooltip = false;
            on-click = "systemctl reboot";
            format = "<span color='${successColor}'></span>";
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
      #custom-mpris, #workspaces, #tray, #privacy, #group-network:hover, #group-power:hover {
        border-radius: 1rem;
        background-color: ${secondaryColor};
      }

      /*
      * ── Group Styles ──────────────────────────────────────────────────────
      */

      /* Left Items */
      #network, #custom-lock {
        margin-left: 0.5rem;
      }

      /* All Modules */
      #network, network.download, network.upload, #custom-shutdown, #custom-lock, #custom-suspend, #custom-reboot {
        background-color: transparent;
      }

      /*
      * ── Top Bar ───────────────────────────────────────────────────────────
      */

      /* Logo */
      #custom-logo {
        margin-left: 0.5rem;
        padding-top: 0.1rem;
        padding-bottom: 0.1rem;
        font-size: 16pt;
      }

      /* Active App */
      #custom-window {
        font-weight: bold;
      }

      /* MPRIS */
      #custom-mpris.spotify {
        color: #1ED760;
      }
      #custom-mpris.youtube {
        color: #CD201F;
      }
      #custom-mpris.firefox, #custom-mpris.default {
        color: ${primaryColor};
      }
      #custom-mpris.paused {
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
    '';
  };
}
