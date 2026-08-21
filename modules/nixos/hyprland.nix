# ╭──────────────────────────────────────────────────────────╮
# │ Hyprland                                                 │
# ╰──────────────────────────────────────────────────────────╯
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  xdg.portal.xdgOpenUsePortal = true;

  # Use Wayland (Electron)
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };
}
