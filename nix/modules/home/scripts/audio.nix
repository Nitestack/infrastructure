{
  pkgs,
  ...
}:
let
  swayosd-client = "${pkgs.swayosd}/bin/swayosd-client";
  wpctl = "${pkgs.wireplumber}/bin/wpctl";

  output-volume = pkgs.writeShellScriptBin "output-volume" ''
    #!/usr/bin/env bash

    SHOW_OSD=false
    if [ "$1" = "--osd" ]; then
        SHOW_OSD=true
        shift
    fi

    ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ -l 1 $1

    if [ "$SHOW_OSD" = true ]; then
      percent="$(${wpctl} get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')"
      progress="$(echo "scale=2; $percent / 100" | bc -l)"

      if [ $((percent)) -eq 100 ]; then
        icon_name="sink-volume-high-symbolic"
      elif [ $((percent)) -ge 50 ]; then
        icon_name="sink-volume-medium-symbolic"
      elif [ $((percent)) -eq 0 ]; then
        icon_name="sink-volume-muted-symbolic"
      else
        icon_name="sink-volume-low-symbolic"
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
{
  output = {
    increase = { osd }: "${output-volume}/bin/output-volume ${if osd then "--osd " else ""}2%+";
    decrease = { osd }: "${output-volume}/bin/output-volume ${if osd then "--osd " else ""}2%-";
    set = { value, osd }: "${output-volume}/bin/output-volume ${if osd then "--osd " else ""}${value}";
    toggle-mute =
      { osd }:
      if osd then
        "${swayosd-client} --output-volume mute-toggle"
      else
        "${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
  };
  input = {
    toggle-mute =
      { osd }:
      if osd then
        "${swayosd-client} --input-volume mute-toggle"
      else
        "${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
  };
}
