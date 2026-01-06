# ╭──────────────────────────────────────────────────────────╮
# │ Dank Material Shell                                      │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  pkgs,
  ...
}:
let
  inherit (flake) inputs;

  uwsm = "${pkgs.uwsm}/bin/uwsm app --";

  dms = "${inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/dms";
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
  wayland.windowManager.hyprland.settings = {
    bindd = [
      "ALT, space, Toggle App Launcher, exec, ${uwsm} ${dms} ipc call spotlight toggle"
      "SUPER, V, Toggle Clipboard History, exec, ${uwsm} ${dms} ipc call clipboard toggle"
      "SUPER, TAB, Toggle Overview, exec, ${uwsm} ${dms} ipc call hypr toggleOverview"
      "CTRL SHIFT, Escape, Toggle System Monitor, exec, ${uwsm} ${dms} ipc call processlist toggle"
      "CTRL SHIFT, Delete, Toggle Power Menu, exec, ${uwsm} ${dms} ipc call powermenu toggle"
    ];
    binddl = [
      ", XF86AudioPlay, Play/Pause, exec, ${uwsm} ${dms} ipc call mpris playPause"
      ", XF86AudioPause, Play/Pause, exec, ${uwsm} ${dms} ipc call mpris playPause"
      ", XF86AudioNext, Skip to Next Track, exec, ${uwsm} ${dms} ipc call mpris next"
      ", XF86AudioPrev, Return to Previous Track, exec, ${uwsm} ${dms} ipc call mpris previous"
    ];
    binddel = [
      ", XF86AudioRaiseVolume, Increase Volume, exec, ${uwsm} ${dms} ipc call audio increment 2"
      ", XF86AudioLowerVolume, Decrease Volume, exec, ${uwsm} ${dms} ipc call audio decrement 2"
      ", XF86AudioMute, Mute/Unmute Volume, exec, ${uwsm} ${dms} ipc call audio mute"
      ", XF86AudioMicMute, Mute/Unmute Microphone, exec, ${uwsm} ${dms} ipc call audio micmute"
    ];
  };
}
