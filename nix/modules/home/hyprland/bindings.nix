# ╭──────────────────────────────────────────────────────────╮
# │ Bindings                                                 │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  pkgs,
  config,
  ...
}:
let
  inherit (flake) inputs;
in
let
  # Bins
  uwsm-app = "${pkgs.uwsm}/bin/uwsm app --";

  cliphist = "${pkgs.cliphist}/bin/cliphist";
  ghostty = "${pkgs.ghostty}/bin/ghostty";
  grimblast = "${inputs.hyprland-contrib.packages.${pkgs.system}.grimblast}/bin/grimblast";
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  hyprpicker = "${pkgs.hyprpicker}/bin/hyprpicker";
  jq = "${pkgs.jq}/bin/jq";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  rofi = "${pkgs.rofi-wayland}/bin/rofi";
  swayosd-client = "${pkgs.swayosd}/bin/swayosd-client --monitor \"$(${hyprctl} monitors -j | ${jq} -r '.[] | select(.focused == true).name')\"";
  wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
  # wezterm = "${pkgs.wezterm}/bin/wezterm";

  cliphist-rofi-img = pkgs.writeShellScriptBin "cliphist-rofi-img" ''
    #!/usr/bin/env bash

    tmp_dir="/tmp/cliphist"
    rm -rf "$tmp_dir"

    if [[ -n "$1" ]]; then
      ${cliphist} decode <<<"$1" | ${wl-copy}
      exit
    fi

    mkdir -p "$tmp_dir"

    read -r -d \'\' prog <<EOF
    /^[0-9]+\s<meta http-equiv=/ { next }
    match(\$0, /^([0-9]+)\s(\[\[\s)?binary.*(jpg|jpeg|png|bmp)/, grp) {
      system("echo " grp[1] "\\\\\t | ${cliphist} decode >$tmp_dir/"grp[1]"."grp[3])
      print \$0"\0icon\x1f$tmp_dir/"grp[1]"."grp[3]
      next
    }
    1
    EOF
    ${cliphist} list | ${pkgs.gawk}/bin/gawk "$prog"
  '';
  screenshots_dir = "${config.xdg.userDirs.pictures}/Screenshots";
in
{
  services.swayosd.enable = true;
  wayland.windowManager.hyprland.settings = {
    "$lmb" = "mouse:272"; # Left mouse button
    "$rmb" = "mouse:273"; # Right mouse button
    "$mmb" = "mouse:274"; # Middle mouse button
    bindd =
      [
        # "SUPER, Slash, Open Terminal, exec, ${uwsm-app} ${wezterm} -e tmux"
        "SUPER, Slash, Open Terminal, exec, ${uwsm-app} ${ghostty} -e tmux"
        "SUPER, E, Open File Manager, exec, ${uwsm-app} org.gnome.Nautilus.desktop"
        "SUPER, W, Open Browser, exec, ${uwsm-app} zen.desktop"
        "CTRL SHIFT, Escape, Open System Monitor, exec, ${uwsm-app} org.gnome.SystemMonitor.desktop"

        "SUPER, V, Open Clipboard History, exec, ${uwsm-app} ${rofi} -modi clipboard:${cliphist-rofi-img}/bin/cliphist-rofi-img -show clipboard -show-icons"
        ", Print, Take Screenshot (Select Area), exec, ${uwsm-app} ${grimblast} --notify --freeze copysave area ${screenshots_dir}/Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"
        "SUPER, Print, Take Fullscreen Screenshot, exec, ${uwsm-app} ${grimblast} --notify --freeze copysave screen ${screenshots_dir}/Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"
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
            wsNo = i + 1;
            wsIndex = if wsNo == 10 then 0 else wsNo;
          in
          [
            "SUPER, ${toString wsIndex}, Switch to Workspace ${toString wsNo}, workspace, ${toString wsNo}"
            "SUPER SHIFT, ${toString wsIndex}, Move Active Window to Workspace ${toString wsNo}, movetoworkspace, ${toString wsNo}"
          ]
        ) 10
      ))
      ++ [
        "SUPER CTRL, H, Switch to Previous Workspace, workspace, e-1"
        "SUPER CTRL, L, Switch to Next Workspace, workspace, e+1"
        "SUPER, mouse_down, Switch to Previous Workspace, workspace, e+1"
        "SUPER, mouse_up, Switch to Next Workspace, workspace, e-1"
        "SUPER SHIFT, H, Move Active Window to Previous Workspace, movetoworkspace, e-1"
        "SUPER SHIFT, L, Move Active Window to Next Workspace, movetoworkspace, e+1"

        "SUPER, S, Toggle Scratchpad, togglespecialworkspace, magic"
        "SUPER SHIFT, S, Move Active Window to Scratchpad, movetoworkspace, special:magic"
      ];
    binddr = [
      "ALT, space, Toggle App Launcher, exec, pkill rofi || ${uwsm-app} ${rofi} -show drun -run-command \"uwsm app -- {cmd}\""
    ];
    bindde = [
      "SUPER ALT, H, Move Window Left, movewindow, l"
      "SUPER ALT, L, Move Window Right, movewindow, r"
      "SUPER ALT, K, Move Window Upwards, movewindow, u"
      "SUPER ALT, J, Move Window Downwards, movewindow, d"
    ];
    binddl = [
      ", XF86AudioPlay, Play/Pause, exec, ${uwsm-app} ${playerctl} play-pause"
      ", XF86AudioPause, Play/Pause, exec, ${uwsm-app} ${playerctl} play-pause"
      ", XF86AudioNext, Skip to Next Track, exec, ${uwsm-app} ${playerctl} next"
      ", XF86AudioPrev, Return to Previous Track, exec, ${uwsm-app} ${playerctl} previous"
    ];
    binddel = [
      ", XF86AudioRaiseVolume, Increase Volume, exec, ${uwsm-app} ${swayosd-client} --output-volume +2"
      ", XF86AudioLowerVolume, Decrease Volume, exec, ${uwsm-app} ${swayosd-client} --output-volume -2"
      ", XF86AudioMute, Mute/Unmute Volume, exec, ${uwsm-app} ${swayosd-client} --output-volume mute-toggle"
      ", XF86AudioMicMute, Mute/Unmute Microphone, exec, ${uwsm-app} ${swayosd-client} --input-volume mute-toggle"

      ", XF86MonBrightnessUp, Increase Screen Brightness, exec, ${uwsm-app} ${swayosd-client} --brightness raise"
      ", XF86MonBrightnessDown, Decrease Screen Brightness, exec, ${uwsm-app} ${swayosd-client} --brightness lower"
    ];
    binddm = [
      "SUPER, $rmb, Resize Window, resizewindow"
      "SUPER, $lmb, Move Window, movewindow"
    ];
  };
}
