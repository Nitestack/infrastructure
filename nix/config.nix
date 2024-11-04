{ pkgs, ... }:
{
  # User Info
  hostname = "nixstation";
  wslHostname = "wslstation";
  username = "nhan";
  description = "Nhan Pham";
  # Theme
  theme = {
    name = "adw-gtk3-dark";
    package = pkgs.adw-gtk3;
  };
  cursorTheme = {
    name = "macOS";
    package = pkgs.apple-cursor;
    size = 24;
  };
  iconTheme = {
    name = "WhiteSur";
    package = pkgs.whitesur-icon-theme.override {
      alternativeIcons = true;
      boldPanelIcons = true;
    };
  };
  # Fonts
  font = {
    sans = {
      name = "Rubik";
      package = pkgs.rubik;
    };
    serif = {
      name = "CrimsonPro";
      package = pkgs.crimson-pro;
    };
    mono = {
      name = "MonaspiceNe Nerd Font Mono";
      package = pkgs.nerdfonts.override {
        fonts = [
          "Iosevka" # For Unicode characters
          "Monaspace"
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
