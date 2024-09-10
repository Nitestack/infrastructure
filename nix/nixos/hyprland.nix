# ╭──────────────────────────────────────────────────────────╮
# │ HYPRLAND                                                 │
# ╰──────────────────────────────────────────────────────────╯

{ pkgs, ... }:
{
  programs.hyprland.enable = true;

  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };

  xdg.portal.enable = true;

  security.polkit.enable = true;

  environment.systemPackages = with pkgs; [
    waybar
    dunst
    kitty
  ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
