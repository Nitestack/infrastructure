# ╭──────────────────────────────────────────────────────────╮
# │ Autostart                                                │
# ╰──────────────────────────────────────────────────────────╯
{
  inputs,
  pkgs,
  meta,
  ...
}:
let
  inherit (meta) cursorTheme;

  # Bins
  cliphist = "${pkgs.cliphist}/bin/cliphist";
  hyprctl = "${inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland}/bin/hyprctl";
  hyprshade = "${pkgs.hyprshade}/bin/hyprshade";
  safeeyes = "${pkgs.safeeyes}/bin/safeeyes";
  snixembed = "${pkgs.snixembed}/bin/snixembed";
  spotify = "${pkgs.spotify}/bin/spotify";
  vesktop = "${pkgs.vesktop}/bin/vesktop";
  wezterm = "${inputs.wezterm.packages.${pkgs.system}.default}/bin/wezterm";
  wl-clip-persist = "${pkgs.wl-clip-persist}/bin/wl-clip-persist";
  wl-paste = "${pkgs.wl-clipboard}/bin/wl-paste";
  zen = "${inputs.zen-browser.packages.x86_64-linux.generic}/bin/zen";
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

      "[workspace 1 silent] ${zen}"
      "[workspace 2 silent] ${wezterm} -e tmux"
      "[workspace 3 silent] ${vesktop}"
      "[workspace 4 silent] ${spotify}"
    ];
    exec = [
      "${hyprshade} auto"
    ];
  };
}
