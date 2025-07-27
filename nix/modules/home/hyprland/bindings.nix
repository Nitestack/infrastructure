# ╭──────────────────────────────────────────────────────────╮
# │ Bindings                                                 │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  pkgs,
  config,
  osConfig,
  lib,
  meta,
  ...
}:
let
  inherit (flake) inputs;
in
let
  # Bins
  uwsm-app = "${pkgs.uwsm}/bin/uwsm app --";

  ghostty = "${pkgs.ghostty}/bin/ghostty";
  hyprctl = "${osConfig.programs.hyprland.package}/bin/hyprctl";
  hyprpicker = "${pkgs.hyprpicker}/bin/hyprpicker";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  rofi = "${pkgs.rofi-wayland}/bin/rofi";
  rofimoji = "${pkgs.rofimoji}/bin/rofimoji";

  backlight = import ../scripts/backlight.nix { inherit pkgs lib meta; };
  screenshot = import ../scripts/screenshots.nix { inherit config inputs pkgs; };
  audio = import ../scripts/audio.nix { inherit pkgs; };
in
{
  wayland.windowManager.hyprland.settings = {
    "$lmb" = "mouse:272"; # Left mouse button
    "$rmb" = "mouse:273"; # Right mouse button
    "$mmb" = "mouse:274"; # Middle mouse button
    bindd = [
      "SUPER, Slash, Open Terminal, exec, ${uwsm-app} ${ghostty} -e tmux"
      "SUPER, E, Open File Manager, exec, ${uwsm-app} org.gnome.Nautilus.desktop"
      "SUPER, W, Open Browser, exec, ${uwsm-app} zen.desktop"
      "CTRL SHIFT, Escape, Open System Monitor, exec, ${uwsm-app} org.gnome.SystemMonitor.desktop"

      ", Print, Take Screenshot (Select Area), exec, ${uwsm-app} ${screenshot.area-select}"
      "SUPER, Print, Take Screenshot (All Monitors), exec, ${uwsm-app} ${screenshot.all-monitors}"
      "ALT, Print, Take Screenshot (Active Window), exec, ${uwsm-app} ${screenshot.active-window}"
      "CTRL, Print, Take Screenshot (Active Monitor), exec, ${uwsm-app} ${screenshot.active-monitor}"
      "SUPER SHIFT, C, Launch Colorpicker, exec, ${uwsm-app} ${hyprpicker} -a"

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

      "SUPER, R, Toggle Split Orientation, togglesplit"
      "SUPER, T, Toggle Active Window Floating, togglefloating"
      "SUPER SHIFT, T, Toggle All Windows Floating, exec, ${uwsm-app} ${hyprctl} dispatch workspaceopt allfloat"
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
    binddr = [
      "ALT, space, Toggle App Launcher, exec, pkill rofi || ${uwsm-app} ${rofi} -show drun -run-command \"${uwsm-app} {cmd}\""
      "SUPER, period, Toggle Emoji Picker, exec, pkill rofi || ${uwsm-app} ${rofimoji}"
    ];
    binddl = [
      ", XF86AudioPlay, Play/Pause, exec, ${uwsm-app} ${playerctl} play-pause"
      ", XF86AudioPause, Play/Pause, exec, ${uwsm-app} ${playerctl} play-pause"
      ", XF86AudioNext, Skip to Next Track, exec, ${uwsm-app} ${playerctl} next"
      ", XF86AudioPrev, Return to Previous Track, exec, ${uwsm-app} ${playerctl} previous"
    ];
    binddel = [
      ", XF86AudioRaiseVolume, Increase Volume, exec, ${uwsm-app} ${
        audio.output.increase { osd = true; }
      }"
      ", XF86AudioLowerVolume, Decrease Volume, exec, ${uwsm-app} ${
        audio.output.decrease { osd = true; }
      }"
      ", XF86AudioMute, Mute/Unmute Volume, exec, ${uwsm-app} ${audio.output.toggle-mute { osd = true; }}"
      ", XF86AudioMicMute, Mute/Unmute Microphone, exec, ${uwsm-app} ${
        audio.input.toggle-mute { osd = true; }
      }"

      ", XF86MonBrightnessUp, Increase Screen Brightness, exec, ${uwsm-app} ${
        backlight.increase { osd = true; }
      }"
      ", XF86MonBrightnessDown, Decrease Screen Brightness, exec, ${uwsm-app} ${
        backlight.decrease { osd = true; }
      }"
    ];
    binddm = [
      "SUPER, $rmb, Resize Window, resizewindow"
      "SUPER, $lmb, Move Window, movewindow"
    ];
  };
}
