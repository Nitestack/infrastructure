# ╭──────────────────────────────────────────────────────────╮
# │ Hyprland                                                 │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, ... }:
{
  programs = {
    hyprland.enable = true;
    hyprlock.enable = true;
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
  };

  security = {
    pam.services = {
      hyprlock = { };
      sddm.enableGnomeKeyring = true;
    };
    polkit.enable = true;
  };
  services.gnome.gnome-keyring.enable = true;

  environment.systemPackages = with pkgs; [
    polkit_gnome
    snixembed
  ];

  # Use Wayland (Electron)
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
