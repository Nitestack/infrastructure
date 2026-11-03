# ╭──────────────────────────────────────────────────────────╮
# │ Bindings                                                 │
# ╰──────────────────────────────────────────────────────────╯
{
  pkgs,
  config,
  lib,
  meta,
  ...
}:
let
  # Bins
  inherit (import ../lib/hyprland.nix { inherit lib pkgs; }) uwsm mkBind;

  backlight = import ../scripts/backlight.nix {
    inherit pkgs lib meta;
  };

  dms = lib.getExe' pkgs.dux-shell "dms";
  dfiles = lib.getExe' pkgs.dux-files "dfiles";

  screenshotDir = "${config.xdg.userDirs.pictures}/Screenshots";

  screenshotCmd = mode: "${dms} screenshot ${mode} --dir ${lib.escapeShellArg screenshotDir}";
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
        (mkBind "SUPER + E" "Open File Manager" "hl.dsp.exec_cmd(\"${uwsm} ${dfiles}\")" { })
        (mkBind "SUPER + W" "Open Browser" "hl.dsp.exec_cmd(\"${uwsm} zen.desktop\")" { })

        # --- Screenshots ---
        (mkBind "Print" "Take Screenshot (Select Area)" "hl.dsp.exec_cmd(\"${uwsm} ${screenshotCmd ""}\")"
          { }
        )
        (mkBind "SUPER + Print" "Take Screenshot (All Monitors)"
          "hl.dsp.exec_cmd(\"${uwsm} ${screenshotCmd "all"}\")"
          { }
        )
        (mkBind "ALT + Print" "Take Screenshot (Active Window)"
          "hl.dsp.exec_cmd(\"${uwsm} ${screenshotCmd "window"}\")"
          { }
        )
        (mkBind "CTRL + Print" "Take Screenshot (Active Monitor)"
          "hl.dsp.exec_cmd(\"${uwsm} ${screenshotCmd "full"}\")"
          { }
        )
        (mkBind "SUPER + SHIFT + C" "Pick Screen Color"
          "hl.dsp.exec_cmd(\"${uwsm} ${dms} color pick --autocopy\")"
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
          "hl.dsp.exec_cmd(\"${uwsm} ${backlight.increase}\")"
          {
            locked = true;
            repeating = true;
          }
        )
        (mkBind "XF86MonBrightnessDown" "Decrease Screen Brightness"
          "hl.dsp.exec_cmd(\"${uwsm} ${backlight.decrease}\")"
          {
            locked = true;
            repeating = true;
          }
        )
        (mkBind "XF86AudioPlay" "Play/Pause" "hl.dsp.exec_cmd(\"${uwsm} ${dms} ipc call mpris playPause\")"
          { locked = true; }
        )
        (mkBind "XF86AudioPause" "Play/Pause" "hl.dsp.exec_cmd(\"${uwsm} ${dms} ipc call mpris playPause\")"
          { locked = true; }
        )
        (mkBind "XF86AudioNext" "Skip to Next Track"
          "hl.dsp.exec_cmd(\"${uwsm} ${dms} ipc call mpris next\")"
          { locked = true; }
        )
        (mkBind "XF86AudioPrev" "Return to Previous Track"
          "hl.dsp.exec_cmd(\"${uwsm} ${dms} ipc call mpris previous\")"
          { locked = true; }
        )
        (mkBind "XF86AudioRaiseVolume" "Increase Volume"
          "hl.dsp.exec_cmd(\"${uwsm} ${dms} ipc call audio increment 2\")"
          {
            locked = true;
            repeating = true;
          }
        )
        (mkBind "XF86AudioLowerVolume" "Decrease Volume"
          "hl.dsp.exec_cmd(\"${uwsm} ${dms} ipc call audio decrement 2\")"
          {
            locked = true;
            repeating = true;
          }
        )
        (mkBind "XF86AudioMute" "Mute/Unmute Volume"
          "hl.dsp.exec_cmd(\"${uwsm} ${dms} ipc call audio mute\")"
          {
            locked = true;
            repeating = true;
          }
        )
        (mkBind "XF86AudioMicMute" "Mute/Unmute Microphone"
          "hl.dsp.exec_cmd(\"${uwsm} ${dms} ipc call audio micmute\")"
          {
            locked = true;
            repeating = true;
          }
        )

        # --- Mouse Controls ---
        (mkBind "SUPER + ${lmb}" "Move Window" "hl.dsp.window.drag()" { mouse = true; })

        (mkBind "ALT + space" "Toggle App Launcher"
          "hl.dsp.exec_cmd(\"${uwsm} ${dms} ipc call spotlight toggle\")"
          { }
        )
        (mkBind "SUPER + V" "Toggle Clipboard History"
          "hl.dsp.exec_cmd(\"${uwsm} ${dms} ipc call clipboard toggle\")"
          { }
        )
        (mkBind "SUPER + TAB" "Toggle Overview"
          "hl.dsp.exec_cmd(\"${uwsm} ${dms} ipc call hypr toggleOverview\")"
          { }
        )
        (mkBind "CTRL + SHIFT + Escape" "Toggle System Monitor"
          "hl.dsp.exec_cmd(\"${uwsm} ${dms} ipc call processlist toggle\")"
          { }
        )
        (mkBind "CTRL + SHIFT + Delete" "Toggle Power Menu"
          "hl.dsp.exec_cmd(\"${uwsm} ${dms} ipc call powermenu toggle\")"
          { }
        )
      ];
    };
}
