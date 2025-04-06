# ╭──────────────────────────────────────────────────────────╮
# │ darwin-rebuild                                           │
# ╰──────────────────────────────────────────────────────────╯
{ flake, pkgs, ... }:
let
  inherit (flake) inputs;

  darwin-rebuild = "${inputs.nix-darwin.packages.${pkgs.system}.default}/bin/darwin-rebuild";

  darwin-switch = pkgs.writeShellScriptBin "darwin-switch" ''
    #!/usr/bin/env bash

    ${darwin-rebuild} switch --flake ~/.dotfiles/nix#macstation $@
  '';
in
{
  environment.systemPackages = [
    darwin-switch
  ];
}
