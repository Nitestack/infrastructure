# ╭──────────────────────────────────────────────────────────╮
# │ NixOS Desktop Home Manager Configuration                 │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  config,
  ...
}:
let
  inherit (flake.inputs) self;
in
{
  # ── Imports ───────────────────────────────────────────────────────────
  imports = [
    self.homeModules.base
    self.homeModules.linux-only
    self.homeModules.gui-only

    self.homeModules.clipse
    self.homeModules.hyprland
    self.homeModules.rofi
    self.homeModules.swaync
    self.homeModules.swayosd
    self.homeModules.theme
    self.homeModules.waybar
    self.homeModules.waypaper
    self.homeModules.zen-browser
  ];

  # Configuration
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    extraConfig = {
      XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.pictures}/Screenshots";
    };
  };

  # Nautilus
  gtk.gtk3.bookmarks =
    let
      home = config.home.homeDirectory;
    in
    [
      "file://${home}/Studium"
      "file://${home}/Games"
      "file://${config.xdg.userDirs.documents}"
      "file://${config.xdg.userDirs.pictures}"
      "file://${config.xdg.userDirs.videos}"
      "file://${config.xdg.userDirs.download}"
      "file://${config.xdg.userDirs.music}"
    ];

  # Programs
  programs.onlyoffice = {
    enable = true;
    settings = {
      UITheme = "theme-contrast-dark";
      titlebar = "custom";
    };
  };

  # ── Services ──────────────────────────────────────────────────────────
  services = {
    easyeffects.enable = true;
    mpris-proxy.enable = true;
    nextcloud-client.enable = true;
  };
}
