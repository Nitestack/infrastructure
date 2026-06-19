# ╭──────────────────────────────────────────────────────────╮
# │ macOS Configuration                                      │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  config,
  pkgs,
  ...
}:
let
  inherit (flake.inputs) self;
  inherit (config) meta;
in
{
  imports = [
    self.darwinModules.base

    self.darwinModules.defaults
    self.darwinModules.homebrew
  ];

  # ── Home Manager ──────────────────────────────────────────────────────
  home-manager.users.${meta.username} = {
    imports = [ (self + /configurations/home/mac.nix) ];
  };

  # Configuration
  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
  ];
  nixpkgs.hostPlatform = "x86_64-darwin";
  networking.hostName = "macstation";

  # Root Access
  security.pam.services.sudo_local = {
    reattach = true;
    touchIdAuth = true;
  };

  system = {
    primaryUser = meta.username;
    configurationRevision = self.rev or self.dirtyRev or null;
    stateVersion = 6;
  };

  # Packages
  homebrew = {
    casks = [
      "ente-auth"
      "ghostty"
      "nextcloud"
      "protonvpn"
      "stremio"
      "zen-browser"
    ];
  };

  # INFO: any package that hasn't a `programs` or `services` entry on Nix Darwin (look at `nixos/linux-only.nix`)
  environment.systemPackages = with pkgs; [
    git
    whatsapp-for-mac
  ];
}
