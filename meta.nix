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
      package = inputs.apple-fonts.packages.${pkgs.system}.sf-pro;
    };
    serif = {
      name = "New York";
      package = inputs.apple-fonts.packages.${pkgs.system}.ny;
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
      boldPanelIcons = true;
    };
  };
  kvantumTheme = {
    name = "catppuccin-mocha-blue";
    package = pkgs.catppuccin-kvantum.override {
      variant = "mocha";
    };
  };
  monitors = [
    {
      name = "DP-2";
      resolution = "1920x1080";
      refreshRate = 144;
      position = {
        x = 0;
        y = 0;
      };
      backlight = {
        i2cBus = "i2c-7";
        device = "ddcci7";
        busName = "AMDGPU DM aux hw bus 1"; # grep -r "AMDGPU DM aux hw bus" /sys/bus/i2c/devices/i2c-7/name
      };
    }
    {
      name = "DP-1";
      resolution = "1920x1080";
      refreshRate = 200;
      position = {
        x = 1920;
        y = 0;
      };
      isDefault = true;
      backlight = {
        i2cBus = "i2c-6";
        device = "ddcci6";
        busName = "AMDGPU DM aux hw bus 0"; # 1rep -r "AMDGPU DM aux hw bus" /sys/bus/i2c/devices/i2c-6/name
      };
    }
  ];
}
