# ╭──────────────────────────────────────────────────────────╮
# │ LOCALE                                                   │
# ╰──────────────────────────────────────────────────────────╯

{ pkgs, ... }:
{
  time.timeZone = "Europe/Berlin";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_IDENTIFICATION = "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "de_DE.UTF-8";
    };
  };
  console = {
    font = "ter-128n";
    keyMap = "us";
    packages = [ pkgs.terminus_font ];
  };
  services.xserver.xkb = {
    layout = "us, us";
    variant = "basic, intl";
    options = "grp:win_space_toggle";
  };
}
