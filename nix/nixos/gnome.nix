{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    dconf-editor
    glib
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
