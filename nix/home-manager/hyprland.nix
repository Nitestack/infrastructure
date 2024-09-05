# ╭──────────────────────────────────────────────────────────╮
# │ HYPRLAND                                                 │
# ╰──────────────────────────────────────────────────────────╯

{ inputs, pkgs, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
    systemd = {
      enable = true;
      variables = [ "--all" ];
    };

    settings = {
      "$lmb" = "mouse:272"; # Left mouse button
      "$rmb" = "mouse:273"; # Right mouse button
      "$mmb" = "mouse:274"; # Middle mouse button
      bindd =
        [
          "SUPER, Slash, Open Terminal, exec, kitty"

          "SUPER, E, Open File Manager, exec, nautilus --new-window"
          "SUPER, W, Open Browser, exec, firefox"

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
          "SUPER SHIFT, T, Toggle All Windows Floating, exec, hyprctl dispatch workspaceopt allfloat"
        ]
        ++ (builtins.concatLists (
          builtins.genList (
            i:
            let
              wsNo = i + 1;
              wsIndex = if wsNo == 10 then 0 else wsNo;
            in
            [
              "SUPER, ${toString (wsIndex)}, Switch to Workspace ${toString (wsNo)}, workspace, ${toString (wsNo)}"
              "SUPER SHIFT, ${toString (wsIndex)}, Move Active Window to Workspace ${toString (wsNo)}, movetoworkspace, ${toString (wsNo)}"
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
      bindde = [
        "ALT, space, Toggle App Launcher, exec, wofi --show drun"

        "SUPER ALT, H, Move Window Left, movewindow, l"
        "SUPER ALT, L, Move Window Right, movewindow, r"
        "SUPER ALT, K, Move Window Upwards, movewindow, u"
        "SUPER ALT, J, Move Window Downwards, movewindow, d"
      ];
      binddm = [
        "SUPER, $rmb, Resize Window, resizewindow"
        "SUPER, $lmb, Move Window, movewindow"
      ];
    };
  };
}
