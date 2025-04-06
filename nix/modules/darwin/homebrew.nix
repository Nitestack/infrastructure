# ╭──────────────────────────────────────────────────────────╮
# │ Homebrew                                                 │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  config,
  pkgs,
  ...
}:
let
  inherit (flake) inputs;
  inherit (config) meta;
in
{
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  nix-homebrew = {
    enable = true;
    enableRosetta = pkgs.system == "aarch64-darwin";
    user = meta.username;
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };
    # Taps can no longer be added imperatively with `brew tap`
    mutableTaps = false;
  };

  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
  };
}
