{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    attrNames
    attrValues
    concatLists
    concatStringsSep
    filter
    filterAttrs
    foldl'
    mapAttrsToList
    mkIf
    unique
    ;

  cfg = config.homestation.homelab;

  enabledServices = filterAttrs (_: service: service.enable) cfg.services;

  duplicates =
    values:
    let
      counts = foldl' (
        acc: value:
        acc
        // {
          ${value} = (acc.${value} or 0) + 1;
        }
      ) { } values;
    in
    filter (value: counts.${value} > 1) (unique values);

  enabledServiceNames = attrNames enabledServices;

  exposedServices = filterAttrs (_: service: service.expose.mode != "none") enabledServices;

  exposedHosts = map (service: service.expose.host) (
    attrValues (filterAttrs (_: service: service.expose.host != null) exposedServices)
  );

  duplicateHosts = duplicates exposedHosts;

  listenerKeys = concatLists (
    mapAttrsToList (
      _: service:
      map (
        listener:
        let
          bind =
            if listener.bind == null then
              if cfg.lanAddress == null then "<lanAddress>" else cfg.lanAddress
            else
              listener.bind;
        in
        "${bind}:${toString listener.hostPort}/${listener.protocol}"
      ) (attrValues service.listeners)
    ) enabledServices
  );

  duplicateListeners = duplicates listenerKeys;

  serviceAssertions = concatLists (
    mapAttrsToList (name: service: [
      {
        assertion = service.expose.mode == "none" || service.expose.host != null;
        message = "homestation.homelab.services.${name} is exposed but has no expose.host.";
      }
      {
        assertion = !service.caddy.enable || service.expose.host != null;
        message = "homestation.homelab.services.${name} enables Caddy but has no expose.host.";
      }
      {
        assertion = !service.caddy.enable || service.expose.port != null;
        message = "homestation.homelab.services.${name} enables Caddy but has no expose.port.";
      }
      {
        assertion = service.expose.mode != "private" || cfg.lanAddress != null;
        message = "homestation.homelab.services.${name} is private but homestation.homelab.lanAddress is null.";
      }
      {
        assertion = builtins.all (
          dependency: builtins.elem dependency enabledServiceNames
        ) service.dependsOn;
        message = "homestation.homelab.services.${name} depends on an unknown or disabled service.";
      }
      {
        assertion = builtins.all (
          listener: listener.exposure != "lan" || listener.bind != null || cfg.lanAddress != null
        ) (attrValues service.listeners);
        message = "homestation.homelab.services.${name} has a LAN listener but no listener.bind or homestation.homelab.lanAddress.";
      }
    ]) enabledServices
  );
in
{
  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.virtualisation.oci-containers.backend == "docker";
        message = "homestation.homelab requires virtualisation.oci-containers.backend = \"docker\".";
      }
      {
        assertion = !config.services.caddy.enable;
        message = "homestation.homelab generates its own Caddy OCI container, so native services.caddy.enable must be false.";
      }
      {
        assertion = duplicateHosts == [ ];
        message = "homestation.homelab has duplicate exposed hostnames: ${concatStringsSep ", " duplicateHosts}.";
      }
      {
        assertion = duplicateListeners == [ ];
        message = "homestation.homelab has duplicate host listeners: ${concatStringsSep ", " duplicateListeners}.";
      }
      {
        assertion = !cfg.caddy.enable || cfg.caddy.containerName != "";
        message = "homestation.homelab.caddy.containerName must not be empty.";
      }
    ]
    ++ serviceAssertions;
  };
}
