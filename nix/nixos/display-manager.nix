# ╭──────────────────────────────────────────────────────────╮
# │ Display Manager                                          │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, ... }:
{
  services.displayManager = {
    sddm = {
      enable = true;
      package = pkgs.kdePackages.sddm;
      extraPackages = with pkgs.kdePackages; [
        qt5compat
        qtsvg
      ];
      theme = "sddm-astronaut-theme";
      wayland.enable = true;
    };
  };
  environment.systemPackages = [
    pkgs.sddm-astronaut-theme
  ];
}
