# ╭──────────────────────────────────────────────────────────╮
# │ Hyprsunset                                               │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, ... }:
let
  startTime = "19:00:00";
  endTime = "06:00:00";
  temperature = 3600;
in
{
  home.packages = [ pkgs.hyprsunset ];

  systemd.user = {
    services.hyprshade = {
      Unit = {
        Description = "Apply blue light filter";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.hyprsunset}/bin/hyprsunset -t ${toString temperature}";
      };
    };
    timers.hyprshade = {
      Unit = {
        Description = "Apply blue light filter on schedule";
      };
      Timer = {
        OnCalendar = [
          "*-*-* ${endTime}"
          "*-*-* ${startTime}"
        ];
      };
      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}
