# ╭──────────────────────────────────────────────────────────╮
# │ Hyprpaper                                                │
# ╰──────────────────────────────────────────────────────────╯
{ config, ... }:
let
  picturesDir = config.xdg.userDirs.pictures;
in
{
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = "${picturesDir}/wallpapers/Fantasy-Landscape3.png";
      wallpaper = ",${picturesDir}/wallpapers/Fantasy-Landscape3.png";
    };
  };
}
