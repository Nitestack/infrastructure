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
      # https://wiki.hyprland.org/Configuring/Environment-variables
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

      # ── Config ────────────────────────────────────────────────────────────
      # https://wiki.hyprland.org/Configuring/Variables

      # Monitors
      # https://wiki.hyprland.org/Configuring/Monitors
      monitor = [
        "DP-1, 1920x1080@144, 0x0, 1"
        # "DP-2, 1920x1080@144, 1920x0, 1" # In case of a second monitor
      ];

      # General
      # https://wiki.hyprland.org/Configuring/Variables/#general
      general = {
        gaps_in = 10; # gaps between windows, also supports css style gaps (top, right, bottom, left -> 5,10,15,20)
        gaps_out = 10; # gaps between windows and monitor edges, also supports css style gaps (top, right, bottom, left -> 5,10,15,20)

        border_size = 3; # size of the border around windows

        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg"; # border color for the active window
        "col.inactive_border" = "rgba(595959aa)"; # border color for inactive windows

        resize_on_border = true; # enables resizing windows by clicking and dragging on borders and gaps

        allow_tearing = true; # master switch for allowing tearing to occur
      };

      # Decoration
      # https://wiki.hyprland.org/Configuring/Variables/#decoration
      decoration = {
        rounding = 10; # rounded corners' radius (in layout px)

        drop_shadow = true; # enable drop shadows on windows
        shadow_ignore_window = true; # if true, the shadow will not be rendered behind the window itself, only around it
        shadow_offset = "2 2"; # shadow’s rendering offset
        shadow_range = 8; # Shadow range (“size”) in layout px
        shadow_render_power = 2; # in what power to render the falloff (more power, the faster the falloff) [1 - 4]
        "col.shadow" = "0x66000000"; # shadow’s color. Alpha dictates shadow’s opacity

        # Blur
        # https://wiki.hyprland.org/Configuring/Variables/#blur
        blur = {
          enabled = true; # enable kawase window background blur
          size = 3; # blur size (distance)
          passes = 2; # the amount of passes to perform
        };
      };

      # Animations
      # https://wiki.hyprland.org/Configuring/Variables/#animations
      animations = {
        enabled = true; # enable animations

        # https://wiki.hyprland.org/Configuring/Animations
        bezier = [
          "overshot, 0.05, 0.9, 0.1, 1.05"
          "smoothOut, 0.36, 0, 0.66, -0.56"
          "smoothIn, 0.25, 1, 0.5, 1"
        ];
        animation = [
          "windows, 1, 5, overshot, slide"
          "windowsOut, 1, 4, smoothOut, slide"
          "windowsMove, 1, 4, default"
          "border, 1, 10, default"
          "fade, 1, 10, smoothIn"
          "fadeDim, 1, 10, smoothIn"
          "workspaces, 1, 6, default"
          "specialWorkspace, 1, 4, default, slidevert"
        ];
      };

      # Input
      # https://wiki.hyprland.org/Configuring/Variables/#input
      input = {
        # Toggle between US QWERTY and US Intl QWERTY layout on `Win + Space`
        # https://wiki.hyprland.org/Configuring/Variables/#xkb-settings
        kb_layout = "us, us";
        kb_variant = "basic, intl";
        kb_model = "";
        kb_options = "grp:win_space_toggle";
        kb_rules = "";

        # Specify if and how cursor movement should affect window focus.
        # https://wiki.hyprland.org/Configuring/Variables/#follow-mouse-cursor
        follow_mouse = 2;

        # Touchpad
        # https://wiki.hyprland.org/Configuring/Variables/#touchpad
        touchpad = {
          natural_scroll = true; # Inverts scrolling direction. When enabled, scrolling moves content directly, rather than manipulating a scrollbar
        };
      };

      # Gestures
      # https://wiki.hyprland.org/Configuring/Variables/#gestures
      gestures = {
        workspace_swipe = true; # enable workspace swipe gesture on touchpad
      };

      # Miscellaneous
      # https://wiki.hyprland.org/Configuring/Variables/#misc
      misc = {
        disable_hyprland_logo = true; # disables the random Hyprland logo / anime girl background
        disable_splash_rendering = true; # disables the Hyprland splash rendering. (requires a monitor reload to take effect)
        force_default_wallpaper = 0; # Enforce any of the 3 default wallpapers. Setting this to 0 or 1 disables the anime background. -1 means “random”
        vrr = 2; # controls the VRR (Adaptive Sync) of your monitors. 0 - off, 1 - on, 2 - fullscreen only
        animate_manual_resizes = true; # If true, will animate manual window resizes/moves
        enable_swallow = true; # Enable window swallowing
      };

      # XWayland
      # https://wiki.hyprland.org/Configuring/Variables/#xwayland
      xwayland = {
        force_zero_scaling = true; # forces a scale of 1 on xwayland windows on scaled displays
      };

      # Dwindle
      # https://wiki.hyprland.org/Configuring/Dwindle-Layout
      dwindle = {
        pseudotile = true; # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
        preserve_split = true;
      };

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
