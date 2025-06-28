# ╭──────────────────────────────────────────────────────────╮
# │ Boot                                                     │
# ╰──────────────────────────────────────────────────────────╯
{
  boot = {
    tmp.cleanOnBoot = true;
    loader = {
      timeout = 60;
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
  };
}
