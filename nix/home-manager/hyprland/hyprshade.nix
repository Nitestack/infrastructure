# ╭──────────────────────────────────────────────────────────╮
# │ Hyprshade                                                │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, ... }:
let
  start_time = "19:00:00";
  end_time = "06:00:00";
in
{
  home.packages = [ pkgs.hyprshade ];

  systemd.user = {
    services.hyprshade = {
      Unit = {
        description = "Apply screen filter";
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.hyprshade}/bin/hyprshade auto";
      };
    };
    timers.hyprshade = {
      Unit = {
        description = "Apply screen filter on schedule";
      };

      Timer = {
        OnCalendar = [
          "*-*-* ${end_time}"
          "*-*-* ${start_time}"
        ];
      };

      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };

  xdg.configFile."hypr/hyprshade.toml".source = (pkgs.formats.toml { }).generate "" {
    shaders = {
      inherit start_time end_time;
      name = "blue-light-filter";
      config = {
        temperature = 3600;
        strength = 1;
      };
    };
  };
}
