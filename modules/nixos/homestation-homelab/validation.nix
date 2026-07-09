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
  hasPublicApps = builtins.any (app: app.expose.mode == "public") (
    builtins.attrValues internal.enabledApps
  );

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
    in
    [
      {
        assertion = app.expose.mode == "none" || internal.effectiveHost appName != null;
        message = "homestation.homelab.apps.${appName}.expose.host must be set when expose.mode != \"none\".";
      }
      {
        assertion =
          app.expose.mode == "none"
          || (
            internal.effectiveExposeService appName != null
            && services.${internal.effectiveExposeService appName}.port != null
          );
        message = "homestation.homelab.apps.${appName}.expose.targetService is required for exposed apps when the app has multiple services, and the selected service must define a port.";
      }
      {
        assertion = app.expose.targetService == null || builtins.elem app.expose.targetService serviceNames;
        message = "homestation.homelab.apps.${appName}.expose.targetService must reference an enabled service in the same app.";
      }
      {
        assertion =
          app.expose.mode != "public" || (cfg.cloudflared.enable && cfg.cloudflared.tunnelId != null);
        message = "homestation.homelab.apps.${appName} uses expose.mode = \"public\" but cloudflared.enable or cloudflared.tunnelId is missing.";
      }
    ]
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
              || (
                volume.type == "library" && volume.library != null && builtins.hasAttr volume.library cfg.libraries
              )
              || (volume.type == "volume" && volume.volume != null)
            )
          ) service.volumes;
          message = "homestation.homelab.apps.${appName}.services.${serviceName}.volumes has an invalid type/source/library/volume combination.";
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
            || (
              !lib.hasPrefix "/" volume.source
              || (volume.owner == "root" && volume.group == "root" && volume.mode == "0755")
            )
          ) service.volumes;
          message = "homestation.homelab.apps.${appName}.services.${serviceName}.volumes sets owner/group/mode on an absolute bind source, but only relative bind sources are managed by the module.";
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
        assertion = cfg.domain != "";
        message = "homestation.homelab.domain must be set when homestation.homelab.enable = true.";
      }
      {
        assertion = cfg.lanAddress != "";
        message = "homestation.homelab.lanAddress must be set when homestation.homelab.enable = true.";
      }
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
        assertion = !hasPublicApps || (cfg.cloudflared.enable && cfg.cloudflared.tunnelId != null);
        message = "homestation.homelab public apps require cloudflared.enable and cloudflared.tunnelId to be set.";
      }
    ]
    ++ appAssertions
    ++ serviceAssertions;
  };
}
