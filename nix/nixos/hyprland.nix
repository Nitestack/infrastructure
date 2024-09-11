# ╭──────────────────────────────────────────────────────────╮
# │ HYPRLAND                                                 │
# ╰──────────────────────────────────────────────────────────╯

{ pkgs, ... }:
{
  programs.hyprland.enable = true;

  xdg.portal.enable = true;

  security.polkit.enable = true;

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    waybar
    dunst
    kitty
  ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
