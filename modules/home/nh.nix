# ╭──────────────────────────────────────────────────────────╮
# │ Nh                                                       │
# ╰──────────────────────────────────────────────────────────╯
{
  config,
  lib,
  pkgs,
  ...
}:
let
  nh = lib.getExe pkgs.nh;
  flakeDir = "${config.home.homeDirectory}/nix-config";
  nix-rebuild = pkgs.writeShellScriptBin "nix-rebuild" ''
    action="$1"
    shift

    if uname -r | grep -qEi 'microsoft'; then
      host="wslstation"
    else
      host="$(hostname)"
    fi

    exec ${nh} os "$action" -H "$host" -- "$@"
  '';

  mkRebuildAction =
    action:
    pkgs.writeShellScriptBin "nix-${action}" ''
      exec ${lib.getExe nix-rebuild} ${action} "$@"
    '';

  darwin-switch = pkgs.writeShellScriptBin "darwin-switch" ''
    exec ${nh} darwin switch -H macstation -- "$@"
  '';

  linuxPackages = map mkRebuildAction [
    "switch"
    "boot"
    "test"
  ];
in
{
  programs.nh = {
    enable = true;
    flake = flakeDir;
    clean.enable = true;
  };

  home.packages = if pkgs.stdenv.isDarwin then [ darwin-switch ] else linuxPackages;
}
