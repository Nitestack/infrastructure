# ╭──────────────────────────────────────────────────────────╮
# │ Bindings                                                 │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  pkgs,
  config,
  lib,
  meta,
  ...
}:
let
  inherit (flake) inputs;

  # Bins
  uwsm = "${pkgs.uwsm}/bin/uwsm app --";

  ghostty = "${pkgs.ghostty}/bin/ghostty";
  hyprpicker = "${pkgs.hyprpicker}/bin/hyprpicker";

  backlight = import ../scripts/backlight.nix { inherit pkgs lib meta; };
  screenshot = import ../scripts/screenshots.nix { inherit config inputs pkgs; };
in
{
  wayland.windowManager.hyprland.settings = {
    "$lmb" = "mouse:272"; # Left mouse button
    "$rmb" = "mouse:273"; # Right mouse button
    "$mmb" = "mouse:274"; # Middle mouse button
    bindd = [
      "SUPER, Slash, Open Terminal, exec, ${uwsm} ${ghostty} -e tmux"
      "SUPER, E, Open File Manager, exec, ${uwsm} org.gnome.Nautilus.desktop"
      "SUPER, W, Open Browser, exec, ${uwsm} zen.desktop"

      ", Print, Take Screenshot (Select Area), exec, ${uwsm} ${screenshot.area-select}"
      "SUPER, Print, Take Screenshot (All Monitors), exec, ${uwsm} ${screenshot.all-monitors}"
      "ALT, Print, Take Screenshot (Active Window), exec, ${uwsm} ${screenshot.active-window}"
      "CTRL, Print, Take Screenshot (Active Monitor), exec, ${uwsm} ${screenshot.active-monitor}"
      "SUPER SHIFT, C, Launch Colorpicker, exec, ${uwsm} ${hyprpicker} -a"

      "SUPER, H, Move Focus to Left Window, movefocus, l"
      "SUPER, L, Move Focus to Right Window, movefocus, r"
      "SUPER, K, Move Focus to Upper Window, movefocus, u"
      "SUPER, J, Move Focus to Lower Window, movefocus, d"

      "SUPER, F, Toggle Fullscreen, fullscreen, 0"
      "SUPER, M, Maximize/Restore Window, fullscreen, 1"

      "SUPER ALT, H, Move Window Left, movewindow, l"
      "SUPER ALT, L, Move Window Right, movewindow, r"
      "SUPER ALT, K, Move Window Upwards, movewindow, u"
      "SUPER ALT, J, Move Window Downwards, movewindow, d"

      "SUPER, Q, Close Active Window, killactive"
      "SUPER, C, Center Window, centerwindow, 1" # `1` respects the monitor reserved area

      "SUPER, T, Toggle Active Window Floating, togglefloating"
    ]
    ++ (builtins.concatLists (
      builtins.genList (
        i:
        let
          wsNo = toString (i + 1);
        in
        [
          "SUPER, ${wsNo}, Switch to Workspace ${wsNo}, split-workspace, ${wsNo}"
          "SUPER SHIFT, ${wsNo}, Move Active Window to Workspace ${wsNo}, split-movetoworkspace, ${wsNo}"
        ]
      ) 5
    ))
    ++ [
      "SUPER CTRL, H, Switch to Previous Workspace, split-cycleworkspaces, prev"
      "SUPER CTRL, L, Switch to Next Workspace, split-cycleworkspaces, next"
      "SUPER, mouse_down, Switch to Previous Workspace, split-cycleworkspaces, prev"
      "SUPER, mouse_up, Switch to Next Workspace, split-cycleworkspaces, next"
      "SUPER SHIFT, H, Move Active Window to Previous Workspace, split-movetoworkspace, -1"
      "SUPER SHIFT, L, Move Active Window to Next Workspace, split-movetoworkspace, +1"
      "SUPER CTRL SHIFT, h, Move Workspace to Previous Monitor, split-changemonitor, prev"
      "SUPER CTRL SHIFT, l, Move Workspace to Next Monitor, split-changemonitor, next"

      "SUPER, S, Toggle Scratchpad, togglespecialworkspace, magic"
      "SUPER SHIFT, S, Move Active Window to Scratchpad, movetoworkspace, special:magic"
    ];
    binddel = [
      ", XF86MonBrightnessUp, Increase Screen Brightness, exec, ${uwsm} ${
        backlight.increase { osd = true; }
      }"
      ", XF86MonBrightnessDown, Decrease Screen Brightness, exec, ${uwsm} ${
        backlight.decrease { osd = true; }
      }"
    ];
    binddm = [
      "SUPER, $rmb, Resize Window, resizewindow"
      "SUPER, $lmb, Move Window, movewindow"
    ];
  };
}
