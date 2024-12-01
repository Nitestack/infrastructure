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
      package = pkgs.nerdfonts.override {
        fonts = [
          "Iosevka" # For Unicode characters
          "GeistMono"
          "NerdFontsSymbolsOnly"
        ];
      };
    };
    emoji = {
      name = "Noto Color Emoji";
      package = pkgs.noto-fonts-color-emoji;
    };
  };
}
