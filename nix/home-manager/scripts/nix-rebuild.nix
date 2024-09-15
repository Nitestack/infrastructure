# ╭──────────────────────────────────────────────────────────╮
# │ NixOS Rebuild                                            │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, meta, ... }:
let
  nixos-rebuild = "${pkgs.nixos-rebuild}/bin/nixos-rebuild";

  nix-switch = pkgs.writeShellScriptBin "nix-switch" ''
    sudo ${nixos-rebuild} switch --flake ~/.dotfiles/nix#${meta.hostname} --impure $@
  '';
  nix-boot = pkgs.writeShellScriptBin "nix-boot" ''
    sudo ${nixos-rebuild} boot --flake ~/.dotfiles/nix#${meta.hostname} --impure $@
  '';
  nix-test = pkgs.writeShellScriptBin "nix-test" ''
    sudo ${nixos-rebuild} test --flake ~/.dotfiles/nix#${meta.hostname} --impure $@
  '';
in
{
  home.packages = [
    nix-switch
    nix-boot
    nix-test
  ];
}
