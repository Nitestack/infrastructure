# ╭──────────────────────────────────────────────────────────╮
# │ Backlight                                                │
# ╰──────────────────────────────────────────────────────────╯
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ ddcutil ];
  boot.extraModulePackages = [ config.boot.kernelPackages.ddcci-driver ];
  boot.kernelModules = [
    "i2c-dev"
    "ddcci_backlight"
  ];
  systemd.services."ddcci@" = {
    scriptArgs = "%i";
    script = ''
      echo Trying to attach ddcci to $1
      i=0
      id=$(echo $1 | cut -d "-" -f 2)
      counter=5
      while [ $counter -gt 0 ]; do
        if ${pkgs.ddcutil}/bin/ddcutil getvcp 10 -b $id; then
          echo ddcci 0x37 > /sys/bus/i2c/devices/$1/new_device
          break
        fi
        sleep 1
        counter=$((counter - 1))
      done
    '';
    serviceConfig.Type = "oneshot";
  };
}
