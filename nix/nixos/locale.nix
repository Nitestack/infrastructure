# ╭──────────────────────────────────────────────────────────╮
# │ Locale                                                   │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, ... }:
{
  time.timeZone = "Europe/Berlin";
  i18n =
    let
      english = "en_US.UTF-8";
      german = "de_DE.UTF-8";
    in
    {
      defaultLocale = english;
      extraLocaleSettings = {
        LC_ADDRESS = german;
        LC_IDENTIFICATION = german;
        LC_MEASUREMENT = german;
        LC_MONETARY = german;
        LC_NAME = german;
        LC_NUMERIC = german;
        LC_PAPER = german;
        LC_TELEPHONE = german;
        LC_TIME = german;
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
