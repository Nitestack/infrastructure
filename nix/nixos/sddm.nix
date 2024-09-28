# ╭──────────────────────────────────────────────────────────╮
# │ Display Manager                                          │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, meta, ... }:
let
  inherit (meta) font;
in
{
  services.displayManager.sddm = {
    enable = true;
    package = pkgs.kdePackages.sddm;
    theme = "catppuccin-mocha";
    wayland.enable = true;
  };
  environment.systemPackages = [
    (pkgs.catppuccin-sddm.override {
      flavor = "mocha";
      font = font.sans.name;
    })
    font.sans.package
  ];
}
