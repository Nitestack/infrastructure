# ╭──────────────────────────────────────────────────────────╮
# │ Waybar                                                   │
# ╰──────────────────────────────────────────────────────────╯
{
  pkgs,
  meta,
  theme,
  osConfig,
  ...
}:
let
  inherit (meta) font;

  rofi = "${pkgs.rofi-wayland}/bin/rofi";
  hyprctl = "${osConfig.programs.hyprland.package}/bin/hyprctl";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  swaync-client = "${pkgs.swaynotificationcenter}/bin/swaync-client";

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
          height = 36;
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
            "custom/swaync"
            "clock"
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
            format = "<tt><small>{name}</small></tt>";
            on-scroll-up = "${hyprctl} dispatch split-cycleworkspaces next";
            on-scroll-down = "${hyprctl} dispatch split-cycleworkspaces prev";
          };
          tray = {
            inherit spacing;
            icon-size = 18;
          };
          "custom/swaync" = {
            tooltip = false;
            exec = "${swaync-client} -swb";
            format = "󰘳{icon}";
            return-type = "json";
            on-click = "${swaync-client} -t -sw";
            escape = true;
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
        }
      ];
    style = pkgs.lib.scss.compileToCss {
      src = ./style.scss;
      variables = {
        bg-color = bgColor;
        text-color = textColor;
        primary-color = primaryColor;
        secondary-color = secondaryColor;
        warning-color = warningColor;
        error-color = errorColor;
        font-sans = font.sans.name;
        font-nerd-propo = font.nerd.propoName;
      };
    };
  };
}
