{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    attrNames
    concatMap
    filter
    genAttrs
    mkIf
    optional
    ;

  cfg = config.homestation.homelab;
  homelab-lib = import ./lib.nix { inherit cfg lib; };
  inherit (homelab-lib)
    appNetworkName
    containerAttrName
    enabledApps
    enabledContainersForApp
    ;

  enabledAppNames = filter (appName: enabledContainersForApp appName != { }) (attrNames enabledApps);

  enabledContainerNames = concatMap (
    appName:
    let
      containers = enabledContainersForApp appName;
    in
    map (containerName: containerAttrName appName containerName containers.${containerName}) (
      attrNames containers
    )
  ) enabledAppNames;

  caddyNames = optional cfg.caddy.enable "homelab-caddy";
  generatedContainerNames = filter (
    name: builtins.hasAttr name config.virtualisation.oci-containers.containers
  ) (enabledContainerNames ++ caddyNames);

  generatedServiceAttrs = map (
    name: config.virtualisation.oci-containers.containers.${name}.serviceName
  ) generatedContainerNames;
  generatedUnitNames = map (name: "${name}.service") generatedServiceAttrs;
  multiContainerAppNames = filter (
    appName: builtins.length (attrNames (enabledContainersForApp appName)) > 1
  ) enabledAppNames;
  generatedNetworkNames = [ cfg.edgeNetwork.name ] ++ map appNetworkName multiContainerAppNames;
in
{
  config = mkIf cfg.enable {
    systemd.services = {
      homelab-network = {
        description = "Create homelab Docker network";
        wantedBy = [ "multi-user.target" ];
        after = [
          "docker.service"
          "docker.socket"
        ];
        requires = [
          "docker.service"
          "docker.socket"
        ];
        before = generatedUnitNames;
        path = [ pkgs.docker ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          ${lib.concatMapStringsSep "\n" (network: ''
            if ! docker network inspect ${lib.escapeShellArg network} >/dev/null 2>&1; then
              docker network create ${lib.escapeShellArg network} >/dev/null || \
                docker network inspect ${lib.escapeShellArg network} >/dev/null
            fi
          '') generatedNetworkNames}
        '';
      };
    }
    // genAttrs generatedServiceAttrs (_: {
      requires = [ "homelab-network.service" ];
      after = [ "homelab-network.service" ];
    });
  };
}
