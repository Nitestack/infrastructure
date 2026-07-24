# ╭──────────────────────────────────────────────────────────╮
# │ Hypridle                                                 │
# ╰──────────────────────────────────────────────────────────╯
{
  pkgs,
  lib,
  osConfig,
  flake,
  ...
}:
let
  inherit (flake) inputs;

  brightnessctl = lib.getExe pkgs.brightnessctl;
  dms = lib.getExe inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default;
  hyprctl = lib.getExe' osConfig.programs.hyprland.package "hyprctl";
in
{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "";
        before_sleep_cmd = "${dms} ipc call lock lock"; # lock before suspend
        after_sleep_cmd = "${hyprctl} dispatch dpms on"; # to avoid having to press a key twice to turn on the display
      };

      listener = [
        {
          timeout = 150; # 2.5min
          on-timeout = "${brightnessctl} -sd dell::kbd_backlight set 0"; # turn off keyboard backlight
          on-resume = "${brightnessctl} -rd dell::kbd_backlight"; # turn on keyboard backlight
        }
        {
          timeout = 150; # 2.5min
          on-timeout = "${brightnessctl} -s set 10"; # set monitor backlight to minimum, avoid 0 on OLED monitor
          on-resume = "${brightnessctl} -r"; # monitor backlight restore
        }
        {
          timeout = 300; # 5min
          on-timeout = "${hyprctl} dispatch dpms off"; # screen off when timeout has passed
          on-resume = "${hyprctl} dispatch dpms on"; # screen on when activity is detected after timeout has fired
        }
        {
          timeout = 600; # 10min
          on-timeout = "${dms} ipc call lock lock"; # lock screen when timeout has passed
        }
      ];
    };
  };
}
