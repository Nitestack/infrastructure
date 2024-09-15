# ╭──────────────────────────────────────────────────────────╮
# │ NixOS Rebuild                                            │
# ╰──────────────────────────────────────────────────────────╯
{
  pkgs,
  meta,
  config,
  ...
}:
let
  nixos-rebuild = "${pkgs.nixos-rebuild}/bin/nixos-rebuild";
  homeDir = config.home.homeDirectory;

  nix-switch = pkgs.writeShellScriptBin "nix-switch" ''
    sudo ${nixos-rebuild} switch --flake ${homeDir}/.dotfiles/nix#${meta.hostname} --impure $@
  '';
  nix-boot = pkgs.writeShellScriptBin "nix-boot" ''
    sudo ${nixos-rebuild} boot --flake ${homeDir}/.dotfiles/nix#${meta.hostname} --impure $@
  '';
  nix-test = pkgs.writeShellScriptBin "nix-test" ''
    sudo ${nixos-rebuild} test --flake ${homeDir}/.dotfiles/nix#${meta.hostname} --impure $@
  '';
in
{
  home.packages = [
    nix-switch
    nix-boot
    nix-test
  ];
}
