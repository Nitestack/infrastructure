# ╭──────────────────────────────────────────────────────────╮
# │ Hyprland                                                 │
# ╰──────────────────────────────────────────────────────────╯
{
  lib,
  config,
  flake,
  pkgs,
  meta,
  osConfig,
  ...
}:
let
  inherit (flake) inputs;
  inherit (meta) monitors maxRefreshRate;
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
    package = osConfig.programs.hyprland.package;
    portalPackage = osConfig.programs.hyprland.portalPackage;
    systemd.enable = false; # disable systemd integration as it conflicts with uwsm
    plugins = [
      inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces
    ];

    settings = {
      # ── Config ────────────────────────────────────────────────────────────

      # Monitors
      monitor = map (
        m:
        let
          mode = "${m.resolution}@${toString m.refreshRate}";
          position = "${toString m.position.x}x${toString m.position.y}";
        in
        "${m.name}, ${mode}, ${position}, ${toString m.scale}"
      ) monitors;

      # General
      general = {
        resize_on_border = true; # enables resizing windows by clicking and dragging on borders and gaps
        allow_tearing = true; # master switch for allowing tearing to occur

        # Snap
        snap = {
          enabled = true;
        };
      };

      # Input
      input.kb_layout = "eu";

      # Miscellaneous
      misc = {
        disable_hyprland_logo = true; # disables the random Hyprland logo / anime girl background
        disable_splash_rendering = true; # disables the Hyprland splash rendering. (requires a monitor reload to take effect)
        force_default_wallpaper = 0; # Enforce any of the 3 default wallpapers. Setting this to 0 or 1 disables the anime background. -1 means “random”
        vrr = 2; # controls the VRR (Adaptive Sync) of your monitors. 0 - off, 1 - on, 2 - fullscreen only
        animate_manual_resizes = true; # If true, will animate manual window resizes/moves
        focus_on_activate = true; # Whether Hyprland should focus an app that requests to be focused (an activate request)
        enable_swallow = true; # Enable window swallowing
      };

      # Binds
      binds = {
        allow_pin_fullscreen = true;
      };

      # XWayland
      xwayland = {
        force_zero_scaling = true; # forces a scale of 1 on xwayland windows on scaled displays
      };

      # Cursor
      cursor = {
        default_monitor = (lib.findFirst (monitor: monitor.isDefault) null monitors).name;
      };

      # Ecosystem
      ecosystem = {
        no_update_news = true;
        no_donation_nag = true;
      };

      # ── Plugins ───────────────────────────────────────────────────────────
      # split-monitor-workspaces
      plugin = {
        split-monitor-workspaces.count = 5;
      };
    };
  };

  home.sessionVariables = {
    # Toolkit Backend Variables
    CLUTTER_BACKEND = "wayland";
    GDK_BACKEND = "wayland,x11,*";
    SDL_VIDEODRIVER = "wayland";

    # Qt Variables
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
  };

  xdg.configFile."uwsm/env".source =
    "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

  xdg.configFile."hypr/xdph.conf".text = ''
    screencopy {
      max_fps = ${toString maxRefreshRate}
      allow_token_by_default = true
    }
  '';

  services.polkit-gnome.enable = true;

  xdg.desktopEntries."org.gnome.Settings" = {
    name = "Settings";
    comment = "Gnome Control Center";
    icon = "org.gnome.Settings";
    exec = "env XDG_CURRENT_DESKTOP=gnome ${pkgs.gnome-control-center}/bin/gnome-control-center";
    categories = [ "X-Preferences" ];
    terminal = false;
  };
}
