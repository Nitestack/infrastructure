# ╭──────────────────────────────────────────────────────────╮
# │ NixOS Desktop Home Manager Configuration                 │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  ...
}:
let
  inherit (flake.inputs) self;
in
{
  # ── Imports ───────────────────────────────────────────────────────────
  imports = [
    self.homeModules.base
    self.homeModules.bare-metal-only
    self.homeModules.interactive-only
    self.homeModules.gui-only

    self.homeModules.hyprland
    self.homeModules.theme
    self.homeModules.zen-browser
  ];

  home.shellAliases.proton-mail = "XDG_SESSION_TYPE=x11 proton-mail";

  # Configuration
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

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
