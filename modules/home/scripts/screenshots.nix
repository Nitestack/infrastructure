{
  config,
  inputs,
  pkgs,
  ...
}:
let
  screenshots_dir = "${config.xdg.userDirs.pictures}/Screenshots";
  grimblast-cmd =
    target:
    "${
      inputs.hyprland-contrib.packages.${pkgs.system}.grimblast
    }/bin/grimblast --notify --freeze copysave ${target} ${screenshots_dir}/Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png";
in
{
  active-monitor = grimblast-cmd "output";
  all-monitors = grimblast-cmd "screen";
  active-window = grimblast-cmd "active";
  area-select = grimblast-cmd "area";
}
