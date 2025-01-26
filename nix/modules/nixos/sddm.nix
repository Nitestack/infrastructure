# ╭──────────────────────────────────────────────────────────╮
# │ SDDM                                                     │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, config, ... }:
let
  inherit (config.meta) font;
in
{
  services.displayManager = {
    sddm = {
      enable = true;
      package = pkgs.kdePackages.sddm;
      theme = "catppuccin-mocha";
      wayland.enable = true;
    };
    defaultSession = "hyprland";
  };
  environment.systemPackages = [
    (pkgs.catppuccin-sddm.override {
      flavor = "mocha";
      font = font.sans.name;
    })
    font.sans.package
  ];
}
