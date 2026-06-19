# ╭──────────────────────────────────────────────────────────╮
# │ NixOS Desktop Configuration                              │
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
    ./hardware-configuration.nix
    ./profiles/applications.nix
    ./profiles/desktop-services.nix
    ./profiles/monitors.nix
    ./profiles/networking.nix

    self.nixosModules.base
    self.nixosModules.linux-only

    self.nixosModules.audio
    self.nixosModules.backlight
    self.nixosModules.boot
    self.nixosModules.dank-material-shell
    self.nixosModules.davinci-resolve
    self.nixosModules.flatpak
    self.nixosModules.games
    self.nixosModules.gnome
    self.nixosModules.hyprland
    self.nixosModules.logiops
  ];

  # ── Home Manager ──────────────────────────────────────────────────────
  home-manager.users.${meta.username} = {
    imports = [ (self + /configurations/home/desktop.nix) ];
  };
}
