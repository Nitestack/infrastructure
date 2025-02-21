# ╭──────────────────────────────────────────────────────────╮
# │ GNOME                                                    │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, ... }:
{
  services = {
    gnome = {
      core-developer-tools.enable = true;
      rygel.enable = false;
    };
    gvfs.enable = true;
    xserver.desktopManager.gnome.enable = true;
  };

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

    devhelp
    gnome-builder

    sysprof
  ];
}
