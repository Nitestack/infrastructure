# ╭──────────────────────────────────────────────────────────╮
# │ Hyprland                                                 │
# ╰──────────────────────────────────────────────────────────╯
{
  programs = {
    hyprland.enable = true;
    hyprlock.enable = true;
  };

  xdg.portal.xdgOpenUsePortal = true;

  security.pam.services.hyprlock = { };
  services.gnome.gnome-keyring.enable = true;

  # Use Wayland (Electron)
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
