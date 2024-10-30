# ╭──────────────────────────────────────────────────────────╮
# │ Hyprshade                                                │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, ... }:
let
  startTime = "19:00:00";
  endTime = "06:00:00";
in
{
  home.packages = [ pkgs.hyprshade ];

  systemd.user = {
    services.hyprshade = {
      Unit = {
        Description = "Apply screen filter";
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.hyprshade}/bin/hyprshade auto";
      };
    };
    timers.hyprshade = {
      Unit = {
        Description = "Apply screen filter on schedule";
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
  xdg.configFile."hypr/hyprshade.toml".text = ''
    [[shaders]]
    name = "blue-light-filter"
    start_time = ${startTime}
    end_time = ${endTime}
    [shaders.config]
    temperature = 3600
    strength = 1
  '';
}
