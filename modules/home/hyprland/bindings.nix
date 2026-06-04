# ╭──────────────────────────────────────────────────────────╮
# │ Bindings                                                 │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  pkgs,
  config,
  lib,
  meta,
  ...
}:
let
  inherit (flake) inputs;

  # Bins
  uwsm = "${pkgs.uwsm}/bin/uwsm app --";

  ghostty = "${pkgs.ghostty}/bin/ghostty";
  hyprpicker = "${pkgs.hyprpicker}/bin/hyprpicker";

  backlight = import ../scripts/backlight.nix { inherit pkgs lib meta; };
  screenshot = import ../scripts/screenshots.nix { inherit config inputs pkgs; };

  mkBind = keys: desc: luaDispatcher: flags: {
    _args = [
      keys
      (lib.generators.mkLuaInline luaDispatcher)
    ]
    ++ lib.optional (flags != { } || desc != "") (
      flags // lib.optionalAttrs (desc != "") { description = desc; }
    );
  };
in
{
  wayland.windowManager.hyprland.settings =
    let
      lmb = "mouse:272"; # Left mouse button
      # rmb = "mouse:273"; # Right mouse button
      # mmb = "mouse:274"; # Middle mouse button
    in
    {
      bind = [
        # --- Applications ---
        (mkBind "SUPER + Slash" "Open Terminal" "hl.dsp.exec_cmd(\"${uwsm} ${ghostty} -e tmux\")" { })
        (mkBind "SUPER + E" "Open File Manager" "hl.dsp.exec_cmd(\"${uwsm} org.gnome.Nautilus.desktop\")"
          { }
        )
        (mkBind "SUPER + W" "Open Browser" "hl.dsp.exec_cmd(\"${uwsm} zen.desktop\")" { })

        # --- Screenshots ---
        (mkBind "Print" "Take Screenshot (Select Area)"
          "hl.dsp.exec_cmd(\"${uwsm} ${screenshot.area-select}\")"
          { }
        )
        (mkBind "SUPER + Print" "Take Screenshot (All Monitors)"
          "hl.dsp.exec_cmd(\"${uwsm} ${screenshot.all-monitors}\")"
          { }
        )
        (mkBind "ALT + Print" "Take Screenshot (Active Window)"
          "hl.dsp.exec_cmd(\"${uwsm} ${screenshot.active-window}\")"
          { }
        )
        (mkBind "CTRL + Print" "Take Screenshot (Active Monitor)"
          "hl.dsp.exec_cmd(\"${uwsm} ${screenshot.active-monitor}\")"
          { }
        )
        (mkBind "SUPER + SHIFT + C" "Launch Colorpicker" "hl.dsp.exec_cmd(\"${uwsm} ${hyprpicker} -a\")"
          { }
        )

        # --- Focus ---
        (mkBind "SUPER + H" "Move Focus to Left Window" "hl.dsp.focus({ direction = \"l\" })" { })
        (mkBind "SUPER + L" "Move Focus to Right Window" "hl.dsp.focus({ direction = \"r\" })" { })
        (mkBind "SUPER + K" "Move Focus to Upper Window" "hl.dsp.focus({ direction = \"u\" })" { })
        (mkBind "SUPER + J" "Move Focus to Lower Window" "hl.dsp.focus({ direction = \"d\" })" { })

        # --- Window State ---
        (mkBind "SUPER + F" "Toggle Fullscreen" "hl.dsp.window.fullscreen({ mode = \"fullscreen\" })" { })
        (mkBind "SUPER + M" "Maximize/Restore Window" "hl.dsp.window.fullscreen({ mode = \"maximized\" })"
          { }
        )

        # --- Move Window ---
        (mkBind "SUPER + ALT + H" "Move Window Left" "hl.dsp.window.move({ direction = \"l\" })" { })
        (mkBind "SUPER + ALT + L" "Move Window Right" "hl.dsp.window.move({ direction = \"r\" })" { })
        (mkBind "SUPER + ALT + K" "Move Window Upwards" "hl.dsp.window.move({ direction = \"u\" })" { })
        (mkBind "SUPER + ALT + J" "Move Window Downwards" "hl.dsp.window.move({ direction = \"d\" })" { })

        # --- Window Actions ---
        (mkBind "SUPER + Q" "Close Active Window" "hl.dsp.window.close()" { })
        (mkBind "SUPER + C" "Center Window" "hl.dsp.window.center()" { })
        (mkBind "SUPER + T" "Toggle Active Window Floating" "hl.dsp.window.float({ action = \"toggle\" })"
          { }
        )
      ]
      ++ [
        (mkBind "SUPER + CTRL + SHIFT + h" "Move Workspace to Previous Monitor"
          "hl.dsp.window.move({ direction = \"left\" })"
          { }
        )
        (mkBind "SUPER + CTRL + SHIFT + l" "Move Workspace to Next Monitor"
          "hl.dsp.window.move({ direction = \"right\" })"
          { }
        )

        # --- Scratchpad ---
        (mkBind "SUPER + S" "Toggle Scratchpad" "hl.dsp.workspace.toggle_special(\"magic\")" { })
        (mkBind "SUPER + SHIFT + S" "Move Active Window to Scratchpad"
          "hl.dsp.window.move({ workspace = \"special:magic\" })"
          { }
        )

        # --- Hardware Controls ---
        (mkBind "XF86MonBrightnessUp" "Increase Screen Brightness"
          "hl.dsp.exec_cmd(\"${uwsm} ${backlight.increase { osd = true; }}\")"
          {
            locked = true;
            repeating = true;
          }
        )
        (mkBind "XF86MonBrightnessDown" "Decrease Screen Brightness"
          "hl.dsp.exec_cmd(\"${uwsm} ${backlight.decrease { osd = true; }}\")"
          {
            locked = true;
            repeating = true;
          }
        )

        # --- Mouse Controls ---
        (mkBind "SUPER + ${lmb}" "Move Window" "hl.dsp.window.drag()" { mouse = true; })
      ];
    };
}
