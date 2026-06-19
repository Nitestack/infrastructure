# ╭──────────────────────────────────────────────────────────╮
# │ Desktop Applications                                     │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (bottles.override {
      removeWarningPopup = true;
    })
    endeavour
    ente-auth
    flacon
    karere
    kid3
    lutris
    mpv # feishin dependency
    proton-vpn
    stremio-linux-shell
  ];
}
