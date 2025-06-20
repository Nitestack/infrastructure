# ╭──────────────────────────────────────────────────────────╮
# │ macOS Configuration                                      │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  config,
  ...
}:
let
  inherit (flake.inputs) self;
  inherit (config) meta;
in
{
  imports = [
    self.nixosModules.base
    self.nixosModules.gui-only

    self.darwinModules.defaults
    self.darwinModules.homebrew
  ];

  # ── Home Manager ──────────────────────────────────────────────────────
  home-manager.users.${meta.username} = {
    imports = [ (self + /configurations/home/mac.nix) ];
  };

  # Configuration
  nixpkgs.hostPlatform = "x86_64-darwin";
  networking.hostName = "macstation";

  # Root Access
  security.pam.services.sudo_local = {
    reattach = true;
    touchIdAuth = true;
  };

  system = {
    configurationRevision = self.rev or self.dirtyRev or null;
    stateVersion = 6;
  };

  # Packages
  homebrew = {
    casks = [
      "ente-auth"
      "nextcloud"
      "ghostty"
      "zen-browser"
    ];
  };
}
