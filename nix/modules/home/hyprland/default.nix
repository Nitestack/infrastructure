# ╭──────────────────────────────────────────────────────────╮
# │ Hyprland                                                 │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  pkgs,
  ...
}:
let
  inherit (flake) inputs;
in
{
  imports =
    with builtins;
    map (fn: ./${fn}) (filter (fn: fn != "default.nix") (attrNames (readDir ./.)))
    ++ [
      ./plugins
    ];

  home.packages = [
    pkgs.brightnessctl
    inputs.hyprland-contrib.packages.${pkgs.system}.grimblast
    pkgs.hyprcursor
    pkgs.hyprpicker
    pkgs.wl-clip-persist
    pkgs.wl-clipboard
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    # package = null;
    portalPackage = null;
    systemd = {
      enable = true;
      variables = [ "--all" ];
    };

    settings = {
      # ── Environment Variables ─────────────────────────────────────────────
      env = [
        # Toolkit Backend Variables
        "CLUTTER_BACKEND,wayland" # Clutter package already has wayland enabled, this variable will force Clutter applications to try and use the Wayland backend
        "GDK_BACKEND,wayland,x11,*" # GTK: Use wayland if available. If not: try x11, then any other GDK backend.
        "SDL_VIDEODRIVER,wayland" # Run SDL2 applications on Wayland. Remove or set to x11 if games that provide older versions of SDL cause compatibility issues

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

      # Monitors
      monitor = [
        "DP-1, 1920x1080@144, 0x0, 1"
        # "DP-2, 1920x1080@144, 1920x0, 1" # In case of a second monitor
      ];

      # General
      general = {
        resize_on_border = true; # enables resizing windows by clicking and dragging on borders and gaps
        allow_tearing = true; # master switch for allowing tearing to occur
      };

      # Input
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
        pseudotile = true; # Master switch for pseudotiling. Enabling is bound to SUPER + P in the keybinds section below
        preserve_split = true;
      };

      # Ecosystem
      ecosystem = {
        no_update_news = true;
        no_donation_nag = true;
      };
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
