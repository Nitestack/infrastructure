# ╭──────────────────────────────────────────────────────────╮
# │ Backlight                                                │
# ╰──────────────────────────────────────────────────────────╯
{ config, pkgs, ... }:
{
  boot.extraModulePackages = with config.boot.kernelPackages; [ ddcci-driver ];
  boot.kernelModules = [
    "ddcci_backlight"
  ];
  # https://wiki.nixos.org/wiki/Backlight#External_Monitors
  services.udev.extraRules =
    let
      bash = "${pkgs.bash}/bin/bash";
      ddcciDev = "AMDGPU DM aux hw bus 0";
      ddcciNode = "/sys/bus/i2c/devices/i2c-6/new_device";
    in
    ''
      SUBSYSTEM=="i2c", ACTION=="add", ATTR{name}=="${ddcciDev}", RUN+="${bash} -c 'sleep 30; printf ddcci\ 0x37 > ${ddcciNode}'"
    '';
}
