{ pkgs, inputs, ... }:
let
  # Title case matches how upstream Catppuccin themes spell their display
  # names; `flavor` is the lower-case form used by package attrs, file names
  # and config values.
  catppuccinFlavor = "Mocha";
  flavor = pkgs.lib.toLower catppuccinFlavor;
  # magnetic-catppuccin-gtk only distinguishes light from dark, so every dark
  # flavour maps onto the same GTK theme.
  gtkShade = if catppuccinFlavor == "Latte" then "Light" else "Dark";
in
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
  inherit catppuccinFlavor;
  gtkTheme = {
    name = "Catppuccin-GTK-Blue-${gtkShade}-Compact";
    package = pkgs.magnetic-catppuccin-gtk.override {
      accent = [ "blue" ];
      shade = pkgs.lib.toLower gtkShade;
      size = "compact";
      tweaks = [ "macos" ];
    };
  };
  cursorTheme = {
    name = "catppuccin-${flavor}-blue-cursors";
    package = pkgs.catppuccin-cursors."${flavor}Blue";
    size = 24;
  };
  iconTheme = {
    name = "WhiteSur";
    package = pkgs.whitesur-icon-theme.override {
      boldPanelIcons = true;
    };
  };
  kvantumTheme = {
    name = "catppuccin-${flavor}-blue";
    package = pkgs.catppuccin-kvantum.override {
      variant = flavor;
    };
  };
}
