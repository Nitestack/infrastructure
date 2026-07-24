{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  screenshots_dir = "${config.xdg.userDirs.pictures}/Screenshots";
  grimblast-cmd =
    target:
    "${
      lib.getExe inputs.hyprland-contrib.packages.${pkgs.stdenv.hostPlatform.system}.grimblast
    } --notify --freeze copysave ${target} ${screenshots_dir}/Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png";
in
{
  active-monitor = grimblast-cmd "output";
  all-monitors = grimblast-cmd "screen";
  active-window = grimblast-cmd "active";
  area-select = grimblast-cmd "area";
}
