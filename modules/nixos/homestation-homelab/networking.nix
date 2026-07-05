{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    attrNames
    filter
    filterAttrs
    genAttrs
    mkIf
    optional
    ;

  cfg = config.homestation.homelab;

  enabledServiceNames = attrNames (filterAttrs (_: service: service.enable) cfg.services);
  caddyNames = optional cfg.caddy.enable cfg.caddy.containerName;
  generatedContainerNames = filter (
    name: builtins.hasAttr name config.virtualisation.oci-containers.containers
  ) (enabledServiceNames ++ caddyNames);

  generatedServiceNames = map (
    name: config.virtualisation.oci-containers.containers.${name}.serviceName
  ) generatedContainerNames;
in
{
  config = mkIf cfg.enable {
    systemd.services = {
      homelab-network = {
        description = "Create homelab Docker network";
        wantedBy = [ "multi-user.target" ];
        before = generatedServiceNames;
        path = [ pkgs.docker ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          docker network inspect ${cfg.network.name} >/dev/null 2>&1 || \
            docker network create ${cfg.network.name}
        '';
      };
    }
    // genAttrs generatedServiceNames (_: {
      requires = [ "homelab-network.service" ];
      after = [ "homelab-network.service" ];
    });
  };
}
