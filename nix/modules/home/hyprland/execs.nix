# ╭──────────────────────────────────────────────────────────╮
# │ Autostart                                                │
# ╰──────────────────────────────────────────────────────────╯
{
  pkgs,
  meta,
  osConfig,
  ...
}:
let
  inherit (meta) cursorTheme;

  # Bins
  uwsm-app = "${pkgs.uwsm}/bin/uwsm app --";
  uwsm-background-service = "${pkgs.uwsm}/bin/uwsm app -t service -s b --";
  uwsm-session-service = "${pkgs.uwsm}/bin/uwsm app -t service -s s --";

  ghostty = "${pkgs.ghostty}/bin/ghostty";
  hyprctl = "${osConfig.programs.hyprland.package}/bin/hyprctl";
  waypaper = "${pkgs.waypaper}/bin/waypaper";
  # wezterm = "${pkgs.wezterm}/bin/wezterm";
in
{
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "${uwsm-background-service} ${waypaper} --restore"

      "${uwsm-session-service} ${hyprctl} setcursor ${cursorTheme.name} ${toString cursorTheme.size} &"

      # left monitor
      "[workspace 1 silent] ${uwsm-app} vesktop.desktop"
      "[workspace 2 silent] ${uwsm-app} spotify.desktop"
      "[workspace 3 silent] ${uwsm-app} smartcode-stremio.desktop"
      "[workspace 4 silent] ${uwsm-app} steam.desktop"

      # right monitor
      "[workspace 6 silent] ${uwsm-app} zen.desktop"
      # "[workspace 7 silent] ${uwsm-app} ${wezterm} -e tmux"
      "[workspace 7 silent] ${uwsm-app} ${ghostty} -e tmux"
      "[workspace 8 silent] ${uwsm-app} proton-mail.desktop"
    ];
    # Stick to the workspaces
    windowrule = [
      "workspace 1 silent, class:^(vesktop)$"
      "workspace 4 silent, class:^(steam)$"
    ];
  };
}
