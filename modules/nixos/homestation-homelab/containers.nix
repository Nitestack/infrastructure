{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    attrValues
    filterAttrs
    mapAttrs
    mkIf
    optionalAttrs
    optionalString
    ;

  cfg = config.homestation.homelab;

  enabledServices = filterAttrs (_: service: service.enable) cfg.services;

  volumeToString = volume: "${volume.source}:${volume.target}${optionalString volume.readOnly ":ro"}";

  listenerToPort =
    listener:
    let
      bind = if listener.bind == null then cfg.lanAddress else listener.bind;
      suffix = optionalString (listener.protocol != "tcp") "/${listener.protocol}";
    in
    "${bind}:${toString listener.hostPort}:${toString listener.containerPort}${suffix}";

  serviceToContainer =
    _: service:
    let
      networks = if service.networks == [ ] then [ cfg.network.name ] else service.networks;
    in
    {
      image = service.image;
      autoStart = service.container.autoStart;
      environment = service.env;
      environmentFiles = service.environmentFiles;
      volumes = map volumeToString service.volumes;
      ports = map listenerToPort (attrValues service.listeners);
      dependsOn = service.dependsOn;
      inherit networks;
      labels = service.container.labels;
      extraOptions = service.container.extraOptions;
    }
    // optionalAttrs (service.command != null) {
      cmd = service.command;
    }
    // optionalAttrs (service.entrypoint != null) {
      entrypoint = service.entrypoint;
    };
in
{
  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers = mapAttrs serviceToContainer enabledServices;
  };
}
