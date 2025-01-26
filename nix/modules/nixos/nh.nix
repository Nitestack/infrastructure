# ╭──────────────────────────────────────────────────────────╮
# │ Nh                                                       │
# ╰──────────────────────────────────────────────────────────╯
{
  pkgs,
  ...
}:
let
  nh = "${pkgs.nh}/bin/nh";

  nix-rebuild = "${pkgs.writeShellScriptBin "nix-rebuild" ''
    #!/usr/bin/env bash
    action="$1"
    shift

    ${nh} os $action ~/.dotfiles/nix -H "$(hostname -s)" -- $@
  ''}/bin/nix-rebuild";
  nix-switch = pkgs.writeShellScriptBin "nix-switch" ''
    #!/usr/bin/env bash

    ${nix-rebuild} switch $@
  '';
  nix-boot = pkgs.writeShellScriptBin "nix-switch" ''
    #!/usr/bin/env bash

    ${nix-rebuild} switch $@
  '';
  nix-test = pkgs.writeShellScriptBin "nix-switch" ''
    #!/usr/bin/env bash

    ${nix-rebuild} switch $@
  '';
  nix-flake-update = pkgs.writeShellScriptBin "nix-flake-update" ''
    #!/usr/bin/env bash

    nix flake update --commit-lock-file --flake ~/.dotfiles/nix $@
  '';
in
{
  programs.nh = {
    enable = true;
    clean.enable = true;
  };
  environment.systemPackages = [
    nix-switch
    nix-boot
    nix-test
    nix-flake-update
  ];
}
