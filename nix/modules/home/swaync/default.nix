# ╭──────────────────────────────────────────────────────────╮
# │ SwayNC                                                   │
# ╰──────────────────────────────────────────────────────────╯
{
  meta,
  pkgs,
  theme,
  lib,
  config,
  flake,
  ...
}:
let
  inherit (flake) inputs;
  inherit (meta) font monitors;

  bluetoothctl = "${pkgs.bluez}/bin/bluetoothctl";
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  hyprpicker = "${pkgs.hyprpicker}/bin/hyprpicker";
  nmcli = "${pkgs.networkmanager}/bin/nmcli";
  swaync-client = "${pkgs.swaynotificationcenter}/bin/swaync-client";
  wpctl = "${pkgs.wireplumber}/bin/wpctl";

  backlight = import ../scripts/backlight.nix { inherit pkgs lib meta; };
  screenshot = import ../scripts/screenshots.nix { inherit config inputs pkgs; };
  audio = import ../scripts/audio.nix { inherit pkgs; };

  close-swaync-cmd = cmd: "${swaync-client} -cp; sleep 1; ${cmd}";

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
        "menubar"
        "buttons-grid"
        "volume"
        "slider#backlight"
        "title"
        "notifications"
        "mpris"
      ];
      widget-config = {
        mpris = {
          loop-carousel = true;
          blacklist = [ "org.mpris.MediaPlayer2.playerctld" ]; # NOTE: fixes duplicate entries
        };
        "buttons-grid" = {
          buttons-per-row = 4;
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
              command = audio.input.toggle-mute { osd = false; };
              update-command = "${wpctl} get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED && echo false || echo true";
            }
            {
              label = "󰕾";
              type = "toggle";
              command = audio.output.toggle-mute { osd = false; };
              update-command = "${wpctl} get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo false || echo true";
            }
            {
              label = "󰂛";
              type = "toggle";
              command = "[[ $SWAYNC_TOGGLE_STATE == true ]] && ${swaync-client} -dn || ${swaync-client} -df";
              update-command = "${swaync-client} -D";
            }
            {
              label = "󰴱";
              command = "${hyprpicker} -a";
            }
          ];
        };
        "menubar" = {
          "menu#screenshot" = {
            label = "󰄀 Screenshot";
            position = "left";
            actions = [
              {
                label = "󱣴 Window";
                command = close-swaync-cmd screenshot.active-window;
              }
              {
                label = "󰩬 Area";
                command = close-swaync-cmd screenshot.area-select;
              }
              {
                label = "󰍹 Screen";
                command = close-swaync-cmd screenshot.active-monitor;
              }
              {
                label = "󰍺 All Screens";
                command = close-swaync-cmd screenshot.all-monitors;
              }
            ];
          };
          "menu#power" = {
            label = " Power Menu";
            position = "right";
            actions = [
              {
                label = " Shutdown";
                command = "systemctl poweroff";
              }
              {
                label = " Reboot";
                command = "systemctl reboot";
              }
              {
                label = " Lock";
                command = "loginctl lock-session";
              }
              {
                label = " Suspend";
                command = "systemctl suspend";
              }
            ];
          };
        };
        volume = {
          label = "󰕾";
          show-per-app = true;
        };
        "slider#backlight" = {
          label = "󰃞";
          cmd_setter = backlight.set {
            osd = false;
            value = "$value";
          };
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
