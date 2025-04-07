# ╭──────────────────────────────────────────────────────────╮
# │ NixOS WSL Configuration                                  │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  config,
  pkgs,
  ...
}:
let
  inherit (flake) inputs;
  inherit (inputs) self;
  inherit (config) meta;
in
{
  imports = [
    inputs.nixos-wsl.nixosModules.default

    self.nixosModules.base
    self.nixosModules.linux-only
  ];
  wsl = {
    enable = true;
    defaultUser = meta.username;
    docker-desktop.enable = true;
    startMenuLaunchers = true;
  };

  # ── Home Manager ──────────────────────────────────────────────────────
  home-manager.users.${meta.username} = {
    imports = [ (self + /configurations/home/wsl.nix) ];
  };

  # Configuration
  nixpkgs.hostPlatform = "x86_64-linux";

  # ── Packages ──────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    # Apps
    evince
  ];
}
