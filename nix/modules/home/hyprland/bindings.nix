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
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  cliphist = "${pkgs.cliphist}/bin/cliphist";
  ghostty = "${pkgs.ghostty}/bin/ghostty";
  gnome-system-monitor = "${pkgs.gnome-system-monitor}/bin/gnome-system-monitor";
  grimblast = "${
    inputs.hyprland-contrib.packages.${pkgs.stdenv.hostPlatform.system}.grimblast
  }/bin/grimblast";
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  nautilus = "${pkgs.nautilus}/bin/nautilus";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  rofi = "${pkgs.rofi-wayland}/bin/rofi";
  wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  # wezterm = "${inputs.wezterm.packages.${pkgs.system}.default}/bin/wezterm";
  zen = "${inputs.zen-browser.packages.${pkgs.system}.default}/bin/zen";

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
  wayland.windowManager.hyprland.settings = {
    "$lmb" = "mouse:272"; # Left mouse button
    "$rmb" = "mouse:273"; # Right mouse button
    "$mmb" = "mouse:274"; # Middle mouse button
    bindd =
      [
        # "SUPER, Slash, Open Terminal, exec, ${wezterm} -e tmux"
        "SUPER, Slash, Open Terminal, exec, ${ghostty} -e tmux"
        "SUPER, E, Open File Manager, exec, ${nautilus} --new-window"
        "SUPER, W, Open Browser, exec, ${zen}"
        "CTRL SHIFT, Escape, Open System Monitor, exec, ${gnome-system-monitor}"

        "SUPER, V, Open Clipboard History, exec, ${rofi} -modi clipboard:${cliphist-rofi-img}/bin/cliphist-rofi-img -show clipboard -show-icons"
        ", Print, Take Screenshot (Select Area), exec, ${grimblast} --notify --freeze copysave area ${screenshots_dir}/Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"
        "SUPER, Print, Take Fullscreen Screenshot, exec, ${grimblast} --notify --freeze copysave screen ${screenshots_dir}/Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"

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

        "SUPER, P, Toggle Focused Window's Pseudo Mode, pseudo"
        "SUPER, R, Toggle Split Orientation, togglesplit"
        "SUPER, T, Toggle Active Window Floating, togglefloating"
        "SUPER SHIFT, T, Toggle All Windows Floating, exec, ${hyprctl} dispatch workspaceopt allfloat"
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
      "ALT, space, Toggle App Launcher, exec, pkill rofi || ${rofi} -show drun"
    ];
    bindde = [
      "SUPER ALT, H, Move Window Left, movewindow, l"
      "SUPER ALT, L, Move Window Right, movewindow, r"
      "SUPER ALT, K, Move Window Upwards, movewindow, u"
      "SUPER ALT, J, Move Window Downwards, movewindow, d"
    ];
    binddl = [
      ", XF86AudioPlay, Play/Pause, exec, ${playerctl} play-pause"
      ", XF86AudioPause, Play/Pause, exec, ${playerctl} play-pause"
      ", XF86AudioNext, Skip to Next Track, exec, ${playerctl} next"
      ", XF86AudioPrev, Return to Previous Track, exec, ${playerctl} previous"
    ];
    binddel = [
      ", XF86AudioRaiseVolume, Increase Volume, exec, ${wpctl} set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+"
      ", XF86AudioLowerVolume, Decrease Volume, exec, ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 2%-"
      ", XF86AudioMute, Mute/Unmute Volume, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ", XF86AudioMicMute, Mute/Unmute Microphone, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle"

      ", XF86MonBrightnessUp, Increase Screen Brightness, exec, ${brightnessctl} s 10%+"
      ", XF86MonBrightnessDown, Decrease Screen Brightness, exec, ${brightnessctl} s 10%-"
    ];
    binddm = [
      "SUPER, $rmb, Resize Window, resizewindow"
      "SUPER, $lmb, Move Window, movewindow"
    ];
  };
}
