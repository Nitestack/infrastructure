{ pkgs, ... }:
{
  # User Info
  hostname = "nixstation";
  wslHostname = "wslstation";
  username = "nhan";
  description = "Nhan Pham";
  # Fonts
  font = {
    sans = {
      name = "Geist";
      package = pkgs.geist-font;
    };
    nerd = {
      name = "GeistMono NF";
      monoName = "GeistMono NFM";
      propoName = "GeistMono NFP";
      packages = with pkgs.nerd-fonts; [
        iosevka
        geist-mono
        symbols-only
      ];
    };
    emoji = {
      name = "Noto Color Emoji";
      package = pkgs.noto-fonts-color-emoji;
    };
  };
}
