# ╭──────────────────────────────────────────────────────────╮
# │ Waypaper                                                 │
# ╰──────────────────────────────────────────────────────────╯
{
  pkgs,
  theme,
  meta,
  ...
}:
let
  inherit (meta) maxRefreshRate;
  wallpapers_dir = "${../../images/wallpapers}";
in
{
  home.packages = with pkgs; [
    waypaper
    mpvpaper
  ];
  services.swww.enable = true;

  xdg.configFile."waypaper/config.ini".source = (pkgs.formats.ini { }).generate "config.ini" {
    Settings = {
      language = "en";
      folder = "${../../images/wallpapers}";
      monitors = "All";
      wallpaper = "${wallpapers_dir}/dark-galaxy.mp4";
      show_path_in_tooltip = false;
      backend = "mpvpaper";
      fill = "fill";
      sort = "name";
      color = theme.variables.accentBgColor;
      subfolders = false;
      all_subfolders = false;
      show_hidden = false;
      show_gifs_only = false;
      zen_mode = "false";
      post_command = "";
      number_of_columns = 3;
      swww_transition_type = "any";
      swww_transition_step = 90;
      swww_transition_angle = 0;
      swww_transition_duration = 2;
      swww_transition_fps = maxRefreshRate;
      mpvpaper_sound = false;
      mpvpaper_options = "";
      use_xdg_state = false;
    };
  };
}
