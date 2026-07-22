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

    path =
      with pkgs;
      [
        git
        openssh
        nodejs
      ]
      ++ (with inputs.llm-agents-nix.packages.${system}; [
        claude-code
        codex
      ]);

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

  # Tailscale's interface is already trusted (see ./tailscale.nix), so no
  # extra firewall rule is needed to reach the server over the tailnet.
}
