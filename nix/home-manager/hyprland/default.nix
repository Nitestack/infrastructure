# ╭──────────────────────────────────────────────────────────╮
# │ Hyprland                                                 │
# ╰──────────────────────────────────────────────────────────╯
{
  inputs,
  pkgs,
  config,
  meta,
  ...
}:
let
  inherit (meta) cursorTheme;

  grimblast_pkg = inputs.hyprland-contrib.packages.${pkgs.stdenv.hostPlatform.system}.grimblast;
  hyprswitch_pkg = inputs.hyprswitch.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  imports = [
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprpaper.nix
    ./hyprshade.nix
    ./waybar.nix
  ];

  home.packages = [
    pkgs.brightnessctl
    grimblast_pkg
    pkgs.hyprcursor
    pkgs.hyprpicker
    hyprswitch_pkg
    pkgs.wl-clip-persist
    pkgs.wl-clipboard
  ];

  xdg.configFile."hypr/hyprswitch.css".text = ''
    .client-index {
      display: none;
    }
  '';

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    xwayland.enable = true;
    systemd = {
      enable = true;
      variables = [ "--all" ];
    };
    plugins = [
      inputs.Hyprspace.packages.${pkgs.system}.Hyprspace
    ];

    settings =
      let
        # Bins
        brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
        cliphist = "${pkgs.cliphist}/bin/cliphist";
        firefox = "${pkgs.firefox}/bin/firefox";
        gnome-system-monitor = "${pkgs.gnome-system-monitor}/bin/gnome-system-monitor";
        grimblast = "${grimblast_pkg}/bin/grimblast";
        hyprctl = "${pkgs.hyprland}/bin/hyprctl";
        hyprshade = "${pkgs.hyprshade}/bin/hyprshade";
        hyprswitch = "${hyprswitch_pkg}/bin/hyprswitch";
        nautilus = "${pkgs.nautilus}/bin/nautilus";
        playerctl = "${pkgs.playerctl}/bin/playerctl";
        rofi = "${pkgs.rofi-wayland}/bin/rofi";
        safeeyes = "${pkgs.safeeyes}/bin/safeeyes";
        snixembed = "${pkgs.snixembed}/bin/snixembed";
        spotify = "${pkgs.spotify}/bin/spotify";
        webcord = "${pkgs.webcord}/bin/webcord";
        wl-clip-persist = "${pkgs.wl-clip-persist}/bin/wl-clip-persist";
        wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
        wl-paste = "${pkgs.wl-clipboard}/bin/wl-paste";
        wpctl = "${pkgs.wireplumber}/bin/wpctl";

        kitty_startup_script = "${pkgs.kitty}/bin/kitty tmux";

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
        # ── Autostart ─────────────────────────────────────────────────────────
        exec-once = [
          "${snixembed} --fork"
          "${safeeyes} -e"
          "${wl-clip-persist} --clipboard regular"
          "${wl-paste} --type text --watch ${cliphist} store"
          "${wl-paste} --type image --watch ${cliphist} store"
          "${hyprswitch} init --show-title --custom-css ${config.xdg.configHome}/hypr/hyprswitch.css &"
          "${hyprctl} setcursor ${cursorTheme.name} ${toString cursorTheme.size}"

          "[workspace 1 silent] ${firefox}"
          "[workspace 2 silent] ${kitty_startup_script}"
          "[workspace 3 silent] ${webcord}"
          "[workspace 4 silent] ${spotify}"
        ];
        exec = [
          "${hyprshade} auto"
        ];

        # ── Environment Variables ─────────────────────────────────────────────
        # https://wiki.hyprland.org/Configuring/Environment-variables
        env = [
          # Toolkit Backend Variables
          "CLUTTER_BACKEND,wayland" # Clutter package already has wayland enabled, this variable will force Clutter applications to try and use the Wayland backend
          "GDK_BACKEND,wayland,x11,*" # GTK: Use wayland if available. If not: try x11, then any other GDK backend.
          "SDL_VIDEODRIVER,wayland,x11" # Run SDL2 applications on Wayland. Remove or set to x11 if games that provide older versions of SDL cause compatibility issues

          # XDG Specifications
          "XDG_CURRENT_DESKTOP,Hyprland"
          "XDG_SESSION_TYPE,wayland"
          "XDG_SESSION_DESKTOP,Hyprland"

          # Qt Variables
          "QT_AUTO_SCREEN_SCALE_FACTOR,1" # Enables automatic scaling, based on the monitor’s pixel density
          "QT_QPA_PLATFORM,wayland;xcb" # Tell Qt applications to use the Wayland backend, and fall back to x11 if Wayland is unavailable
          "QT_WAYLAND_DISABLE_WINDOWDECORATION,1" # Disables window decorations on Qt applications
          "QT_QPA_PLATFORMTHEME,qt6ct" # Tells Qt based applications to pick your theme from qt6ct, use with Kvantum.
          "QT_STYLE_OVERRIDE,kvantum"
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
            "opacity 0.89 override 0.89 override, .*" # Transparency

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

            (f "com.github.GradienceTeam.Gradience")

            (f "pavucontrol")
            (f "nm-connection-editor")
            (f "xdg-desktop-portal")
            (f "xdg-desktop-portal-gnome")

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
            "SUPER, Slash, Open Terminal, exec, ${kitty_startup_script}"
            "SUPER, E, Open File Manager, exec, ${nautilus} --new-window"
            "SUPER, W, Open Browser, exec, ${firefox}"
            "CTRL SHIFT, Escape, Open System Monitor, exec, ${gnome-system-monitor}"

            "ALT, tab, Switch Windows, exec, ${hyprswitch} gui --do-initial-execute"
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
          "SUPER, SUPER_L, Toggle Workspace Overview, overview:toggle"
        ];
        binddrt = [
          "ALT, ALT_L, Close Window Switcher, exec, ${hyprswitch} close"
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
          ", XF86AudioRaiseVolume, Increase Volume, exec, ${wpctl} set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioLowerVolume, Decrease Volume, exec, ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-"
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
  };

  xdg.desktopEntries."org.gnome.Settings" = {
    name = "Settings";
    comment = "Gnome Control Center";
    icon = "org.gnome.Settings";
    exec = "env XDG_CURRENT_DESKTOP=gnome ${pkgs.gnome-control-center}/bin/gnome-control-center";
    categories = [ "X-Preferences" ];
    terminal = false;
  };

  services.safeeyes.enable = true;
}
