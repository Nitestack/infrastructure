# ╭──────────────────────────────────────────────────────────╮
# │ Hyprland                                                 │
# ╰──────────────────────────────────────────────────────────╯
{
  lib,
  config,
  flake,
  pkgs,
  meta,
  ...
}:
let
  inherit (flake) inputs;
  inherit (meta) monitors maxRefreshRate;
  dirEntries = builtins.readDir ./.;
  autoImports = map (name: ./${name}) (
    builtins.filter (
      name: name != "default.nix" && dirEntries.${name} == "regular" && lib.hasSuffix ".nix" name
    ) (builtins.attrNames dirEntries)
  );
  defaultMonitors = builtins.filter (monitor: monitor.isDefault) monitors;
  defaultMonitorCount = builtins.length defaultMonitors;
  defaultMonitor = if defaultMonitorCount == 1 then builtins.head defaultMonitors else null;

  smw-pkg = inputs.split-monitor-workspaces;
in
{
  imports = autoImports ++ [ ./plugins ];

  assertions = [
    {
      assertion = defaultMonitorCount == 1;
      message = "Expected exactly one monitor with `isDefault = true` in `meta.monitors`.";
    }
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null; # let NixOS system handle portals
    systemd.enable = false; # disable systemd integration as it conflicts with uwsm

    settings = {
      # ── Config ────────────────────────────────────────────────────────────

      # Monitors
      monitor = map (m: {
        output = m.name;
        mode = "${m.resolution}@${toString m.refreshRate}";
        position = "${toString m.position.x}x${toString m.position.y}";
        scale = m.scale;
      }) monitors;

      # Configuration
      config = {
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
          default_monitor = if defaultMonitor != null then defaultMonitor.name else "";
        };

        # Ecosystem
        ecosystem = {
          no_update_news = true;
          no_donation_nag = true;
        };
      };
    };

    extraConfig = ''
      package.path = package.path .. ";${smw-pkg}/lua/?.lua;${smw-pkg}/lua/?/init.lua"
      package.cpath = package.cpath .. ";${smw-pkg}/?.so"

      local smw = require("split-monitor-workspaces")

      smw.setup({
          workspace_count = 5,
          enable_wrapping = false,
      })

      local mainMod = "SUPER"
      for i = 1, smw.get_amount_of_workspaces() do
          local n = tostring(i)

          hl.bind(mainMod .. " + " .. n, smw.workspace(n))
          hl.bind(mainMod .. " + SHIFT + " .. n, smw.move_to_workspace(n))
      end

      hl.bind("SUPER + CTRL + H", smw.cycle_workspaces("prev"))
      hl.bind("SUPER + CTRL + L", smw.cycle_workspaces("next"))

      hl.bind("SUPER + mouse_up", smw.cycle_workspaces("prev"))
      hl.bind("SUPER + mouse_down", smw.cycle_workspaces("next"))

      hl.bind("SUPER + SHIFT + H", smw.move_to_workspace("-1"))
      hl.bind("SUPER + SHIFT + L", smw.move_to_workspace("+1"))
    '';
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

  xdg = {
    configFile = {
      "uwsm/env".source = "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";
      "hypr/xdph.conf".text = ''
        screencopy {
          max_fps = ${toString maxRefreshRate}
          allow_token_by_default = true
        }
      '';
    };
    desktopEntries."org.gnome.Settings" = {
      name = "Settings";
      comment = "Gnome Control Center";
      icon = "org.gnome.Settings";
      exec = "env XDG_CURRENT_DESKTOP=gnome ${lib.getExe pkgs.gnome-control-center}";
      categories = [ "X-Preferences" ];
      terminal = false;
    };
  };

  services = {
    polkit-gnome.enable = true;
    gnome-keyring.enable = true;
  };
}
