# ╭──────────────────────────────────────────────────────────╮
# │ Monitors                                                 │
# ╰──────────────────────────────────────────────────────────╯
let
  dp2Width = 1920;
in
{
  meta.monitors = [
    {
      name = "DP-2";
      resolution = "${toString dp2Width}x1080";
      refreshRate = 144;
      position = {
        x = 0;
        y = 0;
      };
      backlight = {
        i2cBus = "i2c-7";
        device = "ddcci7";
        busName = "AMDGPU DM aux hw bus 1"; # grep -r "AMDGPU DM aux hw bus" /sys/bus/i2c/devices/i2c-7/name
      };
    }
    {
      name = "DP-1";
      resolution = "1920x1080";
      refreshRate = 200;
      position = {
        x = dp2Width;
        y = 0;
      };
      isDefault = true;
      backlight = {
        i2cBus = "i2c-6";
        device = "ddcci6";
        busName = "AMDGPU DM aux hw bus 0"; # grep -r "AMDGPU DM aux hw bus" /sys/bus/i2c/devices/i2c-6/name
      };
    }
  ];
}
