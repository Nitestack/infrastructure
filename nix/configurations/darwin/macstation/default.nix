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

    self.darwinModules.darwin-rebuild
  ];

  # ── Home Manager ──────────────────────────────────────────────────────
  home-manager.users.${meta.username} = {
    imports = [ (self + /configurations/home/mac.nix) ];
  };

  # Configuration
  nixpkgs.hostPlatform = "x86_64-darwin";

  system = {
    configurationRevision = self.rev or self.dirtyRev or null;
    stateVersion = 6;
  };
}
