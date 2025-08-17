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

    if uname -r | grep -qEi 'microsoft'; then
      host="wslstation"
    else
      host="nixstation"
    fi

    ${nh} os $action ~/.dotfiles -H $host -- $@
  ''}/bin/nix-rebuild";
  nix-switch = pkgs.writeShellScriptBin "nix-switch" ''
    #!/usr/bin/env bash

    ${nix-rebuild} switch $@
  '';
  nix-boot = pkgs.writeShellScriptBin "nix-boot" ''
    #!/usr/bin/env bash

    ${nix-rebuild} boot $@
  '';
  nix-test = pkgs.writeShellScriptBin "nix-test" ''
    #!/usr/bin/env bash

    ${nix-rebuild} test $@
  '';
  darwin-switch = pkgs.writeShellScriptBin "darwin-switch" ''
    #!/usr/bin/env bash

    ${nh} darwin switch ~/.dotfiles -H macstation -- $@
  '';
in
{
  programs.nh = {
    enable = true;
    clean.enable = true;
  };
  home.packages =
    if pkgs.stdenv.isDarwin then
      [
        darwin-switch
      ]
    else
      [
        nix-switch
        nix-boot
        nix-test
      ];
}
