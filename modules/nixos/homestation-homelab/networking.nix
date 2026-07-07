{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    attrNames
    genAttrs
    mkIf
    ;

  cfg = config.homestation.homelab;

  generatedUnitNames = map (projectName: "arion-${projectName}") (
    attrNames config.virtualisation.arion.projects
  );
in
{
  config = mkIf (cfg.enable && generatedUnitNames != [ ]) {
    systemd.services = {
      homelab-network = {
        description = "Create homelab Docker networks";
        wantedBy = [ "multi-user.target" ];
        after = [
          "docker.service"
          "docker.socket"
        ];
        requires = [
          "docker.service"
          "docker.socket"
        ];
        before = map (name: "${name}.service") generatedUnitNames;
        path = [ pkgs.docker ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          if ! docker network inspect ${lib.escapeShellArg cfg.edgeNetwork.name} >/dev/null 2>&1; then
            docker network create ${lib.escapeShellArg cfg.edgeNetwork.name} >/dev/null || \
              docker network inspect ${lib.escapeShellArg cfg.edgeNetwork.name} >/dev/null
          fi
        '';
      };
    }
    // genAttrs generatedUnitNames (_: {
      requires = [ "homelab-network.service" ];
      after = [ "homelab-network.service" ];
    });
  };
}
