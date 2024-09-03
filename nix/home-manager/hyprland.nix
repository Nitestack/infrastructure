# ╭──────────────────────────────────────────────────────────╮
# │ HYPRLAND                                                 │
# ╰──────────────────────────────────────────────────────────╯

{ inputs, pkgs, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
    systemd = {
      enable = true;
      variables = [ "--all" ];
    };

    settings = {
      bind = [
        "SUPER, Q, killactive"
        "SUPER, Backslash, exec, kitty"
        "ALT, space, exec, wofi --show drun"
        "SUPER, W, exec, firefox"
      ];
    };
  };
}
