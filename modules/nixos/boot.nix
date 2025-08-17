# ╭──────────────────────────────────────────────────────────╮
# │ Boot                                                     │
# ╰──────────────────────────────────────────────────────────╯
{
  boot = {
    tmp.cleanOnBoot = true;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
  };
}
