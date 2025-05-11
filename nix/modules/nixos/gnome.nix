# ╭──────────────────────────────────────────────────────────╮
# │ GNOME                                                    │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, ... }:
{
  services = {
    gnome.core-developer-tools.enable = true;
    xserver = {
      enable = true;
      excludePackages = with pkgs; [ xterm ];
      desktopManager.gnome.enable = true;
    };
  };

  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];

  environment.gnome.excludePackages = with pkgs; [
    baobab
    epiphany
    gnome-text-editor
    gnome-characters
    gnome-console
    gnome-contacts
    gnome-logs
    gnome-maps
    gnome-system-monitor
    gnome-weather
    gnome-connections
    simple-scan
    snapshot
    yelp

    gnome-color-manager

    devhelp
    gnome-builder

    geary
    seahorse
    sysprof
  ];
}
