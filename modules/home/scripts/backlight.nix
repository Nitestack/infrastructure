{
  pkgs,
  lib,
  meta,
  ...
}:
let
  inherit (meta) monitors;

  brightnessctl = lib.getExe pkgs.brightnessctl;
  swayosd-client = lib.getExe' pkgs.swayosd "swayosd-client";

  defaultMonitors = builtins.filter (monitor: monitor.isDefault) monitors;
  defaultMonitorCount = builtins.length defaultMonitors;
  defaultMonitor = if defaultMonitorCount == 1 then builtins.head defaultMonitors else null;
  backlightMonitors = builtins.filter (monitor: monitor.backlight != null) monitors;

  default-device =
    if defaultMonitor != null && defaultMonitor.backlight != null then
      defaultMonitor.backlight.device
    else
      "";
  monitor-backlight = pkgs.writeShellScriptBin "monitor-backlight" ''
    #!/usr/bin/env bash

    LOCK_DIR="/tmp/monitor-backlight.lock"

    if ! mkdir "$LOCK_DIR" 2>/dev/null; then
        exit 1
    fi

    trap 'rmdir "$LOCK_DIR"' EXIT

    SHOW_OSD=false
    if [ "$1" = "--osd" ]; then
        SHOW_OSD=true
        shift
    fi

    ${lib.concatStringsSep "\n" (
      map (monitor: "${brightnessctl} --device ${monitor.backlight.device} set $1 &") backlightMonitors
    )}

    wait

    if [ "$SHOW_OSD" = true ]; then
      percent="$(${brightnessctl} --device ${default-device} get)"
      progress="$(echo "scale=2; $percent / 100" | bc -l)"

      if [ $((percent)) -eq 100 ]; then
        icon_name="display-brightness-high-symbolic"
      elif [ $((percent)) -ge 50 ]; then
        icon_name="display-brightness-medium-symbolic"
      elif [ $((percent)) -eq 0 ]; then
        icon_name="display-brightness-off-symbolic"
      else
        icon_name="display-brightness-low-symbolic"
      fi

      if [ "$percent" == "0" ]; then
        progress="0.001"
      fi

      ${swayosd-client} \
        --custom-icon="$icon_name" \
        --custom-progress="$progress" \
        --custom-progress-text="$percent%"
    fi
  '';
in
assert lib.assertMsg (
  defaultMonitorCount == 1
) "Expected exactly one monitor with `isDefault = true` in `meta.monitors`.";
assert lib.assertMsg (
  builtins.length backlightMonitors > 0
) "Backlight script requires at least one monitor with `backlight` configured.";
assert lib.assertMsg (
  defaultMonitor == null || defaultMonitor.backlight != null
) "The default monitor in `meta.monitors` must define `backlight`.";
{
  increase = { osd }: "${lib.getExe monitor-backlight} ${if osd then "--osd " else ""}5%+";
  decrease = { osd }: "${lib.getExe monitor-backlight} ${if osd then "--osd " else ""}5%-";
  set =
    { value, osd }:
    "${lib.getExe monitor-backlight} ${if osd then "--osd " else ""}${value}";
}
