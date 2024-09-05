# ╭──────────────────────────────────────────────────────────╮
# │ HYPRLAND                                                 │
# ╰──────────────────────────────────────────────────────────╯

{ inputs, pkgs, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;

    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;

    xwayland.enable = true;
    systemd = {
      enable = true;
      variables = [ "--all" ];
    };

    settings = {
      # ── Environment Variables ─────────────────────────────────────────────
      "$system_theme" = "adw-gtk3";
      "$cursor_theme" = "macOS";
      "$cursor_size" = "24";

      env = [
        # Toolkit Backend Variables
        "CLUTTER_BACKEND,wayland" # Clutter package already has wayland enabled, this variable will force Clutter applications to try and use the Wayland backend
        "GDK_BACKEND,wayland,x11,*" # GTK: Use wayland if available. If not: try x11, then any other GDK backend.
        "SDL_VIDEODRIVER,wayland,x11" # Run SDL2 applications on Wayland. Remove or set to x11 if games that provide older versions of SDL cause compatibility issues

        # XDG Specifications
        "XDG_SESSION_DESKTOP,Hyprland"

        # Qt Variables
        "QT_AUTO_SCREEN_SCALE_FACTOR,1" # Enables automatic scaling, based on the monitor’s pixel density
        "QT_QPA_PLATFORM,wayland;xcb" # Tell Qt applications to use the Wayland backend, and fall back to x11 if Wayland is unavailable
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1" # Disables window decorations on Qt applications
        "QT_QPA_PLATFORMTHEME,qt6ct" # Tells Qt based applications to pick your theme from qt6ct, use with Kvantum.
        "QT_STYLE_OVERRIDE,kvantum"

        # Theming Related Variables
        "GTK_THEME,$system_theme" # Set system theme.
        "XCURSOR_SIZE,$cursor_size" # Set cursor size.
        "HYPRCURSOR_SIZE,$cursor_size"
        "XCURSOR_THEME,$cursor_theme" # Set cursor theme.
        "HYPRCURSOR_THEME,$cursor_theme"
      ];

      # ── Windows and Workspace ─────────────────────────────────────────────
      # https://wiki.hyprland.org/Configuring/Window-Rules
      # https://wiki.hyprland.org/Configuring/Workspace-Rules

      windowrule =
        let
          f = regex: "float, ^(${regex})$";
        in
        [
          # Floating windows
          (f "confirm")
          (f "file_progress")
          (f "dialog")

          (f "org.gnome.Calculator")
          (f "org.gnome.Nautilus")
          (f "org.gnome.SystemMonitor")
          (f "nm-connection-editor")
          (f "org.gnome.Settings")
          (f "org.gnome.design.Palette")

          (f "Color Picker")
          (f "dconf-editor")

          (f "com.github.Aylur.ags")
          (f "com.github.GradienceTeam.Gradience")

          "immediate,.*\.exe" # Tearing
        ];

      windowrulev2 = [
        "suppressevent maximize, class:.*"
        "immediate,class:(steam_app)" # Tearing
      ];

      # ── Bindings ──────────────────────────────────────────────────────────
      # https://wiki.hyprland.org/Configuring/Binds
      # SUPER = "Windows" key

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

  xdg.desktopEntries."org.gnome.Settings" = {
    name = "Settings";
    comment = "Gnome Control Center";
    icon = "org.gnome.Settings";
    exec = "env XDG_CURRENT_DESKTOP=gnome ${pkgs.gnome.gnome-control-center}/bin/gnome-control-center";
    categories = [ "X-Preferences" ];
    terminal = false;
  };
}
