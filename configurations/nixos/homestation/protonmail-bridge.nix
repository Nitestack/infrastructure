{
  lib,
  pkgs,
  ...
}:
{
  # Proton Mail Bridge for local IMAP consumers (Paperless mail intake). The
  # upstream module binds the user unit to `graphical-session.target`; this
  # host is headless and lingers, so start it with the user manager instead.
  services.protonmail-bridge = {
    enable = true;
    path = [
      pkgs.gnupg
      pkgs.pass
    ];
  };

  systemd.user.services.protonmail-bridge = {
    wantedBy = lib.mkForce [ "default.target" ];
    after = lib.mkForce [ ];
    # The vault key lives in `pass`; skip startup until the store exists
    # instead of crash-looping before the one-time interactive login.
    unitConfig.ConditionPathExists = "%h/.password-store/.gpg-id";
    serviceConfig.RestartSec = "30s";
  };
}
