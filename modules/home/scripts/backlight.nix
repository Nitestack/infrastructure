{
  pkgs,
  lib,
  meta,
  ...
}:
let
  inherit (meta) monitors;

  dms = lib.getExe' pkgs.dux-shell "dms";
  flock = lib.getExe' pkgs.util-linux "flock";

  backlightMonitors = builtins.filter (monitor: monitor.backlight != null) monitors;

  mkScript =
    action:
    pkgs.writeShellScriptBin "monitor-brightness-${action}" ''
      set -euo pipefail

      # Serialize brightness changes when keys are held down.
      exec 9>"$XDG_RUNTIME_DIR/monitor-brightness.lock"
      ${flock} -x 9

      ${lib.concatMapStringsSep "\n" (
        monitor: "${dms} ipc call brightness ${action} 5 backlight:${monitor.backlight.device}"
      ) backlightMonitors}
    '';
in
assert lib.assertMsg (
  builtins.length backlightMonitors > 0
) "Brightness control requires at least one configured monitor.";
{
  increase = lib.getExe (mkScript "increment");
  decrease = lib.getExe (mkScript "decrement");
}
