{ pkgs, ... }:
{
  services = {
    xserver.desktopManager.gnome.enable = true;
    gnome = {
      sushi.enable = true;
      core-developer-tools.enable = true;
    };

  };

  environment.gnome.excludePackages = (
    with pkgs;
    [
      baobab
      epiphany
      gnome-text-editor
      gnome-console
      gnome-contacts
      gnome-logs
      gnome-maps
      gnome-system-monitor
      gnome-weather
      gnome-connections
      snapshot
      yelp

      devhelp
      gnome-builder
    ]
  );
}
