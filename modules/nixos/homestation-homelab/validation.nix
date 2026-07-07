{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    attrNames
    concatMap
    concatStringsSep
    filter
    foldl'
    mkIf
    unique
    ;

  cfg = config.homestation.homelab;
  internal = cfg._internal;

  invalidAppNames = filter (appName: builtins.match "[a-zA-Z0-9_-]+" appName == null) (
    attrNames cfg.apps
  );

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

  duplicateHosts = duplicates (
    map internal.effectiveHost (
      filter (
        appName:
        internal.enabledApps.${appName}.expose.mode != "none" && internal.effectiveHost appName != null
      ) (attrNames internal.enabledApps)
    )
  );

  duplicateProjectNames = duplicates (map internal.appProjectName (attrNames internal.enabledApps));

  duplicateContainerNames = duplicates (
    concatMap (
      appName:
      let
        enabledServices = internal.enabledServicesForApp appName;
      in
      map (serviceName: internal.serviceContainerName appName enabledServices serviceName) (
        attrNames enabledServices
      )
    ) (attrNames internal.enabledApps)
  );

  appAssertions = concatMap (
    appName:
    let
      app = internal.enabledApps.${appName};
      services = internal.enabledServicesForApp appName;
      serviceNames = attrNames services;
      routes = internal.resolvedRoutesForApp appName;
    in
    [
      {
        assertion = app.expose.mode == "none" || internal.effectiveHost appName != null;
        message = "homestation.homelab.apps.${appName}.expose.host must be set when expose.mode != \"none\".";
      }
      {
        assertion = app.expose.mode == "none" || cfg.lanAddress != null;
        message = "homestation.homelab.apps.${appName} uses expose.mode = \"${app.expose.mode}\" but lanAddress is not set — LAN address resolution and Caddy ingress require it.";
      }
      {
        assertion = app.expose.mode != "public" || cfg.cloudflared.wildcardIngress;
        message = "homestation.homelab.apps.${appName} uses expose.mode = \"public\" but cloudflared.wildcardIngress is false.";
      }
      {
        assertion = routes != [ ] || app.expose.mode == "none";
        message = "homestation.homelab.apps.${appName} is exposed but has no resolved routes.";
      }
      {
        assertion =
          app.expose.mode == "none" || app.routes != [ ] || internal.effectiveExposeService appName != null;
        message = "homestation.homelab.apps.${appName}.expose.service is required for exposed apps when routes are not declared and the app has multiple services.";
      }
      {
        assertion = app.expose.service == null || builtins.elem app.expose.service serviceNames;
        message = "homestation.homelab.apps.${appName}.expose.service must reference an enabled service in the same app.";
      }
    ]
  ) (attrNames internal.enabledApps);

  routeAssertions = concatMap (
    appName:
    let
      services = internal.enabledServicesForApp appName;
    in
    lib.imap0 (index: route: {
      assertion =
        route.upstream.service != null
        && builtins.hasAttr route.upstream.service services
        && services.${route.upstream.service}.port != null;
      message = "homestation.homelab.apps.${appName}.routes.${toString index} must reference an enabled service with a defined port.";
    }) (internal.resolvedRoutesForApp appName)
  ) (attrNames internal.enabledApps);

  serviceAssertions = concatMap (
    appName:
    let
      services = internal.enabledServicesForApp appName;
    in
    concatMap (
      serviceName:
      let
        service = services.${serviceName};
      in
      [
        {
          assertion = builtins.all (dep: builtins.hasAttr dep services) (attrNames service.dependsOn);
          message = "homestation.homelab.apps.${appName}.services.${serviceName}.dependsOn references a missing service.";
        }
        {
          assertion = builtins.all (
            volume:
            builtins.elem volume.type [
              "bind"
              "library"
              "volume"
            ]
            && (
              (volume.type == "bind" && volume.source != null)
              || (volume.type == "library" && volume.name != null && builtins.hasAttr volume.name cfg.libraries)
              || (volume.type == "volume" && volume.name != null)
            )
          ) service.volumes;
          message = "homestation.homelab.apps.${appName}.services.${serviceName}.volumes has an invalid type/source/name combination.";
        }
        {
          assertion = builtins.all (
            volume:
            volume.type != "bind"
            || volume.source == null
            || lib.hasPrefix "/" volume.source
            || (!lib.hasPrefix ".." volume.source && !lib.hasInfix "/.." volume.source)
          ) service.volumes;
          message = "homestation.homelab.apps.${appName}.services.${serviceName}.volumes contains a relative bind source that escapes the app data directory.";
        }
        {
          assertion = builtins.all (
            volume:
            volume.type != "bind"
            || volume.source == null
            || !(lib.hasPrefix "/" volume.source)
            || volume.hostPath.enable
            || (
              volume.hostPath.user == "root" && volume.hostPath.group == "root" && volume.hostPath.mode == "0755"
            )
          ) service.volumes;
          message = "homestation.homelab.apps.${appName}.services.${serviceName}.volumes has an absolute bind source with hostPath ownership settings but hostPath.enable = false — the settings will have no effect.";
        }
        {
          assertion =
            let
              overlap = builtins.filter (
                cap: builtins.elem cap service.privileges.capabilities.drop
              ) service.privileges.capabilities.add;
            in
            overlap == [ ];
          message = "homestation.homelab.apps.${appName}.services.${serviceName} has the same capability in both privileges.capabilities.add and .drop.";
        }
      ]
    ) (attrNames services)
  ) (attrNames internal.enabledApps);
in
{
  config = mkIf cfg.enable {
    assertions = [
      {
        assertion =
          let
            configured = [
              (cfg.smtp.host != null)
              (cfg.smtp.port != null)
              (cfg.smtp.from != null)
              (cfg.smtp.username != null)
            ];
            enabledCount = builtins.length (builtins.filter (x: x) configured);
          in
          enabledCount == 0 || enabledCount == 4;
        message = "homestation.homelab.smtp requires host, port, from, and username to be set together.";
      }
      {
        assertion = config.virtualisation.arion.backend == "docker";
        message = "homestation.homelab requires virtualisation.arion.backend = \"docker\".";
      }
      {
        assertion = invalidAppNames == [ ];
        message = "homestation.homelab.apps: app names must only contain letters, digits, hyphens, and underscores: ${concatStringsSep ", " invalidAppNames}.";
      }
      {
        assertion = !cfg.caddy.enable || !config.services.caddy.enable;
        message = "homestation.homelab generates its own Caddy OCI container, so native services.caddy.enable must be false.";
      }
      {
        assertion = duplicateHosts == [ ];
        message = "homestation.homelab has duplicate exposed hostnames: ${concatStringsSep ", " duplicateHosts}.";
      }
      {
        assertion = duplicateProjectNames == [ ];
        message = "homestation.homelab has duplicate generated Arion project names after normalization: ${concatStringsSep ", " duplicateProjectNames}.";
      }
      {
        assertion = duplicateContainerNames == [ ];
        message = "homestation.homelab has duplicate generated container names after normalization: ${concatStringsSep ", " duplicateContainerNames}.";
      }
      {
        assertion = cfg.network.prefix != "";
        message = "homestation.homelab.network.prefix must not be empty (would produce Docker network names with a leading dash).";
      }
      {
        assertion =
          !cfg.cloudflared.wildcardIngress
          || (cfg.cloudflared.enable && cfg.cloudflared.tunnelId != null && cfg.domain != null);
        message = "homestation.homelab.cloudflared.wildcardIngress requires cloudflared.enable, cloudflared.tunnelId, and domain to be set.";
      }
    ]
    ++ appAssertions
    ++ routeAssertions
    ++ serviceAssertions;
  };
}
