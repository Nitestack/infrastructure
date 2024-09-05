{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    dconf-editor
    glib
    gnome-control-center
  ];

  services.xserver.desktopManager.gnome.enable = true;

  environment.gnome.excludePackages = (
    with pkgs;
    [
      epiphany
      gnome-console
    ]
  );
}
