# ╭──────────────────────────────────────────────────────────╮
# │ Dank Material Shell                                      │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  pkgs,
  lib,
  ...
}:
let
  inherit (flake) inputs;

  uwsm = "${pkgs.uwsm}/bin/uwsm app --";

  dms = "${inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/dms";

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
  imports = [
    inputs.dms.homeModules.dank-material-shell
  ];

  programs.dank-material-shell = {
    enable = true;
    systemd.enable = true;
    enableSystemMonitoring = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
  };
  wayland.windowManager.hyprland.settings.bind = [
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

    # --- Media Controls (previously binddl - locked) ---
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

    # --- Volume Controls (previously binddel - locked & repeating) ---
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
  ];
}
