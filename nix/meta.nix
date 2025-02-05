{ pkgs, ... }:
{
  # User Info
  username = "nhan";
  description = "Nhan Pham";
  # Fonts
  font = {
    sans = {
      name = "Geist";
      package = pkgs.geist-font;
    };
    nerd = {
      name = "CommitMono Nerd Font";
      monoName = "CommitMono Nerd Font Mono";
      propoName = "CommitMono Nerd Font Propo";
      italic = {
        name = "VictorMono NF";
        monoName = "VictorMono NFM";
        propoName = "VictorMono NFP";
      };
      packages = with pkgs.nerd-fonts; [
        commit-mono
        victor-mono
        iosevka
        symbols-only
      ];
    };
    emoji = {
      name = "Noto Color Emoji";
      package = pkgs.noto-fonts-color-emoji;
    };
  };
  # Themes
  gtkTheme = {
    name = "Catppuccin-GTK-Dark";
    package = pkgs.magnetic-catppuccin-gtk.override {
      tweaks = [ "macos" ];
    };
  };
  cursorTheme = {
    name = "catppuccin-mocha-blue-cursors";
    package = pkgs.catppuccin-cursors.mochaBlue;
    size = 24;
  };
  iconTheme = {
    name = "WhiteSur";
    package = pkgs.whitesur-icon-theme.override {
      alternativeIcons = true;
      boldPanelIcons = true;
    };
  };
  kvantumTheme = {
    name = "catppuccin-mocha-blue";
    package = pkgs.catppuccin-kvantum.override {
      variant = "mocha";
    };
  };
}
