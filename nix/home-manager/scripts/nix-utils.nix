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
  nh = "${pkgs.nh}/bin/nh";
  homeDir = config.home.homeDirectory;

  nix-switch = pkgs.writeShellScriptBin "nix-switch" ''
    #!/usr/bin/env bash

    if command -v "nixos-wsl-version" &>/dev/null; then
      ${nh} os switch ${homeDir}/.dotfiles/nix -H ${meta.wslHostname} -- --impure $@
    elif command -v "nixos-version" &>/dev/null; then
      ${nh} os switch ${homeDir}/.dotfiles/nix -H ${meta.hostname} -- --impure $@
    fi
  '';
  nix-boot = pkgs.writeShellScriptBin "nix-boot" ''
    #!/usr/bin/env bash

    if command -v "nixos-wsl-version" &>/dev/null; then
      ${nh} os boot ${homeDir}/.dotfiles/nix -H ${meta.wslHostname} -- --impure $@
    elif command -v "nixos-version" &>/dev/null; then
      ${nh} os boot ${homeDir}/.dotfiles/nix -H ${meta.hostname} -- --impure $@
    fi
  '';
  nix-test = pkgs.writeShellScriptBin "nix-test" ''
    #!/usr/bin/env bash

    if command -v "nixos-wsl-version" &>/dev/null; then
      ${nh} os test ${homeDir}/.dotfiles/nix -H ${meta.wslHostname} -- --impure $@
    elif command -v "nixos-version" &>/dev/null; then
      ${nh} os test ${homeDir}/.dotfiles/nix -H ${meta.hostname} -- --impure $@
    fi
  '';

  nix-flake-update = pkgs.writeShellScriptBin "nix-flake-update" ''
    #!/usr/bin/env bash

    nix flake update --commit-lock-file ${homeDir}/.dotfiles/nix $@
  '';
in
{
  home.packages = [
    nix-switch
    nix-boot
    nix-test
    nix-flake-update
  ];
}
