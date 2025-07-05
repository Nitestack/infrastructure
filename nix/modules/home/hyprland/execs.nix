# ╭──────────────────────────────────────────────────────────╮
# │ Autostart                                                │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  pkgs,
  meta,
  config,
  ...
}:
let
  inherit (flake) inputs;
  inherit (meta) cursorTheme;

  # Bins
  cliphist = "${pkgs.cliphist}/bin/cliphist";
  ghostty = "${pkgs.ghostty}/bin/ghostty";
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  proton-mail = "${pkgs.protonmail-desktop}/bin/proton-mail";
  steam = "${pkgs.steam}/bin/steam";
  stremio = "${pkgs.stremio}/bin/stremio";
  spotify = "${config.programs.spicetify.spicedSpotify}/bin/spotify";
  vesktop = "${pkgs.vesktop}/bin/vesktop";
  waypaper = "${pkgs.waypaper}/bin/waypaper";
  # wezterm = "${pkgs.wezterm}/bin/wezterm";
  wl-clip-persist = "${pkgs.wl-clip-persist}/bin/wl-clip-persist";
  wl-paste = "${pkgs.wl-clipboard}/bin/wl-paste";
  zen = "${inputs.zen-browser.packages.${pkgs.system}.default}/bin/zen";
in
{
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "${waypaper} --restore"
      "${wl-clip-persist} --clipboard regular"
      "${wl-paste} --type text --watch ${cliphist} store"
      "${wl-paste} --type image --watch ${cliphist} store"
      "${hyprctl} setcursor ${cursorTheme.name} ${toString cursorTheme.size} &"

      # left monitor
      "[workspace 1 silent] ${vesktop}"
      "[workspace 2 silent] ${spotify}"
      "[workspace 3 silent] ${stremio}"
      "[workspace 4 silent] ${steam}"

      # right monitor
      "[workspace 6 silent] ${zen}"
      # "[workspace 7 silent] ${wezterm} -e tmux"
      "[workspace 7 silent] ${ghostty} -e tmux"
      "[workspace 8 silent] ${proton-mail}"
    ];
  };
}
