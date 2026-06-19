# ╭──────────────────────────────────────────────────────────╮
# │ Shared Nushell System Configuration                      │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, ... }:
{
  environment = {
    systemPackages = with pkgs; [ nushell ];
    shells = [
      "/run/current-system/sw/bin/nu"
      "${pkgs.nushell}/bin/nu"
    ];
  };
}
