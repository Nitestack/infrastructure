# ╭──────────────────────────────────────────────────────────╮
# │ Backlight                                                │
# ╰──────────────────────────────────────────────────────────╯
{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (config) meta;
  inherit (meta) monitors;
in
{
  boot.extraModulePackages = with config.boot.kernelPackages; [ ddcci-driver ];
  boot.kernelModules = [
    "ddcci-backlight"
  ];
  # https://wiki.nixos.org/wiki/Backlight#External_Monitors
  services.udev.extraRules =
    let
      bash = "${pkgs.bash}/bin/bash";
    in
    lib.concatStringsSep "\n" (
      map (
        monitor:
        let
          inherit (monitor) backlight;
          ddcciNode = "/sys/bus/i2c/devices/${backlight.i2cBus}/new_device";
        in
        ''
          SUBSYSTEM=="i2c", ACTION=="add", ATTR{name}=="${backlight.busName}", RUN+="${bash} -c 'sleep 30; printf ddcci\ 0x37 > ${ddcciNode}'"
        ''
      ) (builtins.filter (monitor: monitor.backlight != null) monitors)
    );
}
