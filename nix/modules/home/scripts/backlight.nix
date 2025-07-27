{
  pkgs,
  lib,
  meta,
  ...
}:
let
  inherit (meta) monitors;

  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  swayosd-client = "${pkgs.swayosd}/bin/swayosd-client";

  default-device = (lib.findFirst (monitor: monitor.isDefault) null monitors).backlight.device;
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
      map (monitor: "${brightnessctl} --device ${monitor.backlight.device} set $1 &") monitors
    )}

    wait

    if [ "$SHOW_OSD" = true ]; then
      percent="$(${brightnessctl} --device ${default-device} get)"
      progress="$(echo "scale=2; $percent / 100" | bc -l)"

      if [ "$percent" == "0" ]; then
        progress="0.001"
      fi

      ${swayosd-client} \
        --custom-icon="display-brightness-symbolic" \
        --custom-progress="$progress" \
        --custom-progress-text="$percent%"
    fi
  '';
in
{
  increase = { osd }: "${monitor-backlight}/bin/monitor-backlight ${if osd then "--osd " else ""}5%+";
  decrease = { osd }: "${monitor-backlight}/bin/monitor-backlight ${if osd then "--osd " else ""}5%-";
  set =
    { value, osd }:
    "${monitor-backlight}/bin/monitor-backlight ${if osd then "--osd " else ""}${value}";
}
