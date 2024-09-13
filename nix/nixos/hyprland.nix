# ╭──────────────────────────────────────────────────────────╮
# │ HYPRLAND                                                 │
# ╰──────────────────────────────────────────────────────────╯
{pkgs, ...}: {
  programs = {
    hyprland.enable = true;
    hyprlock.enable = true;
  };

  xdg.portal.enable = true;

  security = {
    pam.services.hyprlock = {};
    polkit.enable = true;
  };
  services.hypridle.enable = true;

  systemd = {
    user = {
      services = {
        polkit-gnome-authentication-agent-1 = {
          description = "polkit-gnome-authentication-agent-1";
          wantedBy = ["graphical-session.target"];
          wants = ["graphical-session.target"];
          after = ["graphical-session.target"];
          serviceConfig = {
            Type = "simple";
            ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
            Restart = "on-failure";
            RestartSec = 1;
            TimeoutStopSec = 10;
          };
        };
        hyprshade = {
          description = "Apply screen filter";

          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.hyprshade}/bin/hyprshade auto";
          };
        };
      };
      timers.hyprshade = {
        description = "Apply screen filter on schedule";

        timerConfig = {
          OnCalendar = [
            "*-*-* 06:00:00"
            "*-*-* 19:00:00"
          ];
        };

        wantedBy = ["timers.target"];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    brightnessctl
    cliphist
    dunst
    hyprpicker
    hyprshade
    kitty
    polkit_gnome
    safeeyes
    waybar
    wl-clip-persist
    wl-clipboard

    snixembed
  ];

  # Use Wayland (Electron)
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
