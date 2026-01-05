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
  uwsm = "${pkgs.uwsm}/bin/uwsm app --";

  cliphist = "${pkgs.cliphist}/bin/cliphist";
  ghostty = "${pkgs.ghostty}/bin/ghostty";
  hyprctl = "${osConfig.programs.hyprland.package}/bin/hyprctl";
  wl-paste = "${pkgs.wl-clipboard}/bin/wl-paste";
in
{
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "${uwsm} ${hyprctl} setcursor ${cursorTheme.name} ${toString cursorTheme.size} &"
      "${uwsm} ${wl-paste} --watch ${cliphist} store &"

      # left monitor
      "[workspace 6 silent] ${uwsm} vesktop.desktop"
      "[workspace 7 silent] ${uwsm} com.github.th_ch.youtube_music.desktop"
      "[workspace 8 silent] ${uwsm} smartcode-stremio.desktop"
      "[workspace 9 silent] ${uwsm} steam.desktop"

      # right monitor
      "[workspace 1 silent] ${uwsm} zen.desktop"
      "[workspace 2 silent] ${uwsm} ${ghostty} -e tmux"
      "[workspace 3 silent] ${uwsm} proton-mail.desktop"
    ];
    # Stick to the workspaces
    windowrule = [
      "workspace 6 silent, match:class ^(vesktop)$"
      "workspace 7 silent, match:class ^(com.github.th_ch.youtube_music)$"
      "workspace 9 silent, match:class ^(steam)$"
    ];
  };
}
