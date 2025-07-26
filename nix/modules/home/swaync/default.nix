# ╭──────────────────────────────────────────────────────────╮
# │ SwayNC                                                   │
# ╰──────────────────────────────────────────────────────────╯
{
  meta,
  pkgs,
  theme,
  lib,
  config,
  ...
}:
let
  inherit (meta) font monitors;

  bluetoothctl = "${pkgs.bluez}/bin/bluetoothctl";
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  nmcli = "${pkgs.networkmanager}/bin/nmcli";
  swaync-client = "${pkgs.swaynotificationcenter}/bin/swaync-client";
  wpctl = "${pkgs.wireplumber}/bin/wpctl";

  monitor-backlight = pkgs.writeShellScriptBin "monitor-backlight" ''
    #!/usr/bin/env bash

    DEVICES=(${lib.escapeShellArgs (map (monitor: monitor.backlight.device) monitors)})

    for device in "''${DEVICES[@]}"; do
      ${brightnessctl} --device $device set $1
    done
  '';

  inherit (config.wayland.windowManager.hyprland.settings.general) gaps_out;
in
{
  services.swaync = {
    enable = true;
    settings = {
      notification-inline-replies = true;
      hide-on-clear = true;
      control-center-margin-top = gaps_out;
      control-center-margin-right = gaps_out;
      control-center-margin-bottom = gaps_out;
      notification-visibility = {
        block-spotify = {
          state = "ignored";
          app-name = "Spotify";
        };
      };
      widgets = [
        "buttons-grid#power"
        "mpris"
        "buttons-grid#controls"
        "volume"
        "slider#backlight"
        "title"
        "notifications"
      ];
      widget-config = {
        "buttons-grid#power" = {
          buttons-per-row = 4;
          actions = [
            {
              label = "";
              command = "systemctl poweroff";
            }
            {
              label = "";
              command = "systemctl reboot";
            }
            {
              label = "";
              command = "loginctl lock-session";
            }
            {
              label = "";
              command = "systemctl suspend";
            }
          ];
        };
        mpris = {
          loop-carousel = true;
          blacklist = [ "org.mpris.MediaPlayer2.playerctld" ]; # NOTE: fixes duplicate entries
        };
        "buttons-grid#controls" = {
          buttons-per-row = 6;
          actions = [
            {
              label = "󰖩";
              type = "toggle";
              command = "[[ $SWAYNC_TOGGLE_STATE == true ]] && ${nmcli} networking on || ${nmcli} networking off";
              update-command = "${nmcli} networking | grep -q enabled && echo true || echo false";
            }
            {
              label = "󰂯";
              type = "toggle";
              command = "[[ $SWAYNC_TOGGLE_STATE == true ]] && ${bluetoothctl} power on || ${bluetoothctl} power off";
              update-command = "${bluetoothctl} show | grep -q 'Powered: yes' && echo true || echo false";
            }
            {
              label = "";
              type = "toggle";
              command = "systemctl --user is-active --quiet hyprsunset.service && systemctl --user stop hyprsunset.service || systemctl --user start hyprsunset.service";
              update-command = "pgrep -x hyprsunset > /dev/null && echo true || echo false";
            }
            {
              label = "󰍬";
              type = "toggle";
              command = "${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
              update-command = "${wpctl} get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED && echo false || echo true";
            }
            {
              label = "󰕾";
              type = "toggle";
              command = "${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
              update-command = "${wpctl} get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo false || echo true";
            }
            {
              label = "󰤄";
              type = "toggle";
              command = "[[ $SWAYNC_TOGGLE_STATE == true ]] && ${swaync-client} -dn || ${swaync-client} -df";
              update-command = "${swaync-client} -D";
            }
          ];
        };
        volume = {
          label = "󰕾";
          show-per-app = true;
        };
        "slider#backlight" = {
          label = "󰃞";
          cmd_setter = "${monitor-backlight}/bin/monitor-backlight $value";
          cmd_getter = "${brightnessctl} --device ${
            (lib.findFirst (monitor: monitor.isDefault) null monitors).backlight.device
          } get";
          min = 0;
          max = 100;
          min_limit = 0;
          max_limit = 100;
          value_scale = 0;
        };
        title = {
          text = "󰂚 Notifications";
          button-text = "󰩹";
        };
        notifications = {
        };
      };
    };
    style = pkgs.lib.scss.compileToCss {
      src = ./style.scss;
      variables =
        let
          inherit (theme.variables)
            windowBgColor
            windowFgColor
            accentBgColor
            errorBgColor
            headerbarBorderColor
            headerbarBgColor
            ;
        in
        {
          font-sans = font.sans.name;
          font-nerd-propo = font.nerd.propoName;
          bg-color = windowBgColor;
          text-color = windowFgColor;
          primary-color = accentBgColor;
          border-color = headerbarBorderColor;
          bg-darker = headerbarBgColor;
          error-color = errorBgColor;
          window-border-radius = toString config.wayland.windowManager.hyprland.settings.decoration.rounding;
        };
    };
  };
  xdg.configFile."swaync/config.json".onChange = ''
    ${swaync-client} -R
  '';
  xdg.configFile."swaync/style.css".onChange = ''
    ${swaync-client} -rs
  '';
}
