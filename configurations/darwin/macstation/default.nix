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
    self.darwinModules.interactive-only

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
    "electron-40.10.5"
  ];
  nixpkgs.hostPlatform = "aarch64-darwin";
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
    git-lfs
    tailscale-gui
    whatsapp-for-mac
  ];
}
