{ pkgs, inputs, ... }:
{
  # User Info
  username = "nhan";
  description = "Nhan Pham";
  git = {
    userName = "Nitestack";
    userEmail = "code@npham.de";
  };
  # Fonts
  font = {
    sans = {
      name = "SF Pro Text";
      titleName = "SF Pro Display";
      package = inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.sf-pro;
    };
    serif = {
      name = "New York Medium";
      package = inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.ny;
    };
    nerd = {
      name = "0xProto Nerd Font";
      monoName = "0xProto Nerd Font Mono";
      propoName = "0xProto Nerd Font Propo";
      packages = with pkgs.nerd-fonts; [
        _0xproto
        iosevka
      ];
    };
    emoji = {
      name = "Noto Color Emoji";
      package = pkgs.noto-fonts-color-emoji;
    };
  };
  # Themes
  gtkTheme = {
    name = "Catppuccin-GTK-Blue-Dark-Compact";
    package = pkgs.magnetic-catppuccin-gtk.override {
      accent = [ "blue" ];
      size = "compact";
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
