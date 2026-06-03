# ╭──────────────────────────────────────────────────────────╮
# │ Autostart                                                │
# ╰──────────────────────────────────────────────────────────╯
{
  pkgs,
  meta,
  osConfig,
  lib,
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
    on = {
      _args = [
        "hyprland.start"
        (lib.generators.mkLuaInline ''
          function()
            hl.exec_cmd("${uwsm} ${hyprctl} setcursor ${cursorTheme.name} ${toString cursorTheme.size}")
            hl.exec_cmd("${uwsm} ${wl-paste} --watch ${cliphist} store")

            -- left monitor
            hl.exec_cmd("${uwsm} vesktop.desktop", { workspace = "6" })
            hl.exec_cmd("${uwsm} spotify.desktop", { workspace = "7" })
            hl.exec_cmd("${uwsm} com.stremio.Stremio.desktop", { workspace = "8" })

            -- right monitor
            hl.exec_cmd("${uwsm} zen.desktop", { workspace = "1" })
            hl.exec_cmd("${uwsm} ${ghostty} -e tmux", { workspace = "2" })
            hl.exec_cmd("${uwsm} proton-mail.desktop", { workspace = "3" })
          end
        '')
      ];
    };
    # Stick to the workspaces
    window_rule = [
      {
        match.class = "^(vesktop)$";
        workspace = "6 silent";
      }
      {
        match.class = "^(spotify)$";
        workspace = "7 silent";
      }
    ];
  };
}
