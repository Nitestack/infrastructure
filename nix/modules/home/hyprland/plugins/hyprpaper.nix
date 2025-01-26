# ╭──────────────────────────────────────────────────────────╮
# │ Hyprpaper                                                │
# ╰──────────────────────────────────────────────────────────╯
let
  wallpaper = ../../../../images/wallpapers/Fantasy-Landscape3.png;
in
{
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = "${wallpaper}";
      wallpaper = ",${wallpaper}";
    };
  };
}
