# ╭──────────────────────────────────────────────────────────╮
# │ GNOME                                                    │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, ... }:
{
  services = {
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
  };

  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];

  environment.systemPackages = with pkgs; [
    dconf-editor
  ];

  environment.gnome.excludePackages = with pkgs; [
    # Disabling GNOME core apps
    baobab
    epiphany
    gnome-text-editor
    gnome-characters
    gnome-console
    # gnome-contacts
    gnome-logs
    # gnome-maps
    gnome-music
    gnome-system-monitor
    gnome-weather
    gnome-connections
    yelp

    # Disabling GNOME core shell apps
    adwaita-icon-theme
    gnome-backgrounds
    gnome-color-manager
    gnome-tour
    gnome-user-docs

    # Disabling programs
    geary
    seahorse
  ];
}
