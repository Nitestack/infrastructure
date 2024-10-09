# ╭──────────────────────────────────────────────────────────╮
# │ Autostart                                                │
# ╰──────────────────────────────────────────────────────────╯
{
  inputs,
  pkgs,
  config,
  meta,
  ...
}:
let
  inherit (meta) cursorTheme;

  # Bins
  cliphist = "${pkgs.cliphist}/bin/cliphist";
  firefox = "${pkgs.firefox}/bin/firefox";
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  hyprshade = "${pkgs.hyprshade}/bin/hyprshade";
  safeeyes = "${pkgs.safeeyes}/bin/safeeyes";
  snixembed = "${pkgs.snixembed}/bin/snixembed";
  spotify = "${pkgs.spotify}/bin/spotify";
  webcord = "${pkgs.webcord}/bin/webcord";
  wl-clip-persist = "${pkgs.wl-clip-persist}/bin/wl-clip-persist";
  wl-paste = "${pkgs.wl-clipboard}/bin/wl-paste";

  kitty_startup_script = "${pkgs.kitty}/bin/kitty tmux";
in
{
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "${snixembed} --fork"
      "${safeeyes} -e"
      "${wl-clip-persist} --clipboard regular"
      "${wl-paste} --type text --watch ${cliphist} store"
      "${wl-paste} --type image --watch ${cliphist} store"
      "${hyprctl} setcursor ${cursorTheme.name} ${toString cursorTheme.size}"

      "[workspace 1 silent] ${firefox}"
      "[workspace 2 silent] ${kitty_startup_script}"
      "[workspace 3 silent] ${webcord}"
      "[workspace 4 silent] ${spotify}"
    ];
    exec = [
      "${hyprshade} auto"
    ];
  };
}
