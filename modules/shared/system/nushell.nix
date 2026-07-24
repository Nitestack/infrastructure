# ╭──────────────────────────────────────────────────────────╮
# │ Shared Nushell System Configuration                      │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, lib, ... }:
{
  environment = {
    systemPackages = with pkgs; [ nushell ];
    shells = [
      "/run/current-system/sw/bin/nu"
      (lib.getExe pkgs.nushell)
    ];
  };
}
