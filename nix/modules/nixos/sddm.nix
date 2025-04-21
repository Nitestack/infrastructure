# ╭──────────────────────────────────────────────────────────╮
# │ SDDM                                                     │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, ... }:
{
  services.displayManager = {
    sddm = {
      enable = true;
      package = pkgs.kdePackages.sddm;
      theme = "sddm-astronaut-theme";
      wayland.enable = true;
      extraPackages = with pkgs; [
        kdePackages.qtmultimedia
        kdePackages.qtsvg
        kdePackages.qtvirtualkeyboard
      ];
    };
    defaultSession = "hyprland";
  };
  environment.systemPackages = [
    (pkgs.sddm-astronaut.override {
      embeddedTheme = "jake_the_dog";
      themeConfig = {
        DateFormat = "\"dddd, MMMM d\"";
        HourFormat = "\"HH:mm\"";
      };
    })
  ];
}
