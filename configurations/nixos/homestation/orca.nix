# ╭──────────────────────────────────────────────────────────╮
# │ Orca Remote Server                                       │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  config,
  pkgs,
  ...
}:
let
  inherit (flake) inputs;
  inherit (config) meta;

  system = pkgs.stdenv.hostPlatform.system;
  orca = inputs.orca-nix.packages.${system}.default;
in
{
  environment.systemPackages = [ orca ];

  # Lets the user's systemd manager start at boot and keep running after logout.
  users.users.${meta.username}.linger = true;

  systemd.user.services.orca-server = {
    description = "Orca Remote Server";
    wantedBy = [ "default.target" ];

    # `systemd.user.services` applies to every user's manager, so scope it down.
    unitConfig.ConditionUser = meta.username;

    serviceConfig = {
      ExecStart = ''
        ${orca}/bin/orca serve \
          --port 6768 \
          --pairing-address server.tail9dadb1.ts.net
      '';
      WorkingDirectory = "%h";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
