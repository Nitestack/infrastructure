# ╭──────────────────────────────────────────────────────────╮
# │ Orca Remote Server                                       │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (flake) inputs;
  inherit (config) meta;

  system = pkgs.stdenv.hostPlatform.system;
  orca = inputs.orca-nix.packages.${system}.default;
in
{
  # Lets the user's systemd manager start at boot and keep running after logout.
  users.users.${meta.username}.linger = true;

  systemd.user.services.orca-server = {
    description = "Orca Remote Server";
    wantedBy = [ "default.target" ];

    environment = {
      ORCA_STARTUP_DIAGNOSTICS = "1";
      LIBGL_ALWAYS_SOFTWARE = "1";
    };

    path = with pkgs; [
      xvfb
    ];

    serviceConfig = {
      ExecStart = ''
        ${lib.getExe orca} serve \
          --port 6768 \
          --pairing-address server.tail9dadb1.ts.net
      '';
      WorkingDirectory = "%h";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
