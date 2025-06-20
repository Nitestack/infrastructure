# ╭──────────────────────────────────────────────────────────╮
# │ GNOME                                                    │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, ... }:
{
  services = {
    gnome.core-apps.enable = false;
    xserver = {
      enable = true;
      excludePackages = with pkgs; [ xterm ];
      desktopManager.gnome.enable = true;
    };
    displayManager.gdm.enable = true;
  };

  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];

  environment.systemPackages = with pkgs; [
    decibels
    gnome-calculator
    gnome-calendar
    gnome-clocks
    gnome-font-viewer
    loupe
    nautilus
    totem

    dconf-editor
  ];

  environment.gnome.excludePackages = with pkgs; [
    # Disabling GNOME core apps
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
