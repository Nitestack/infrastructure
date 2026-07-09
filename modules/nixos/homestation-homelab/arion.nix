{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    hasPrefix
    listToAttrs
    mapAttrs
    mapAttrs'
    mkIf
    nameValuePair
    optional
    optionalAttrs
    optionalString
    ;

  cfg = config.homestation.homelab;
  internal = cfg._internal;
  username = config.meta.username;
  userUid = config.users.users.${username}.uid;
  userGid = config.ids.gids.users;

  resolveBindSource =
    appName: volume:
    if volume.source == null then
      throw "bind volume for app '${appName}' has null source (validation should have caught this)"
    else if hasPrefix "/" volume.source then
      volume.source
    else
      "${cfg.dataDir}/${appName}/${volume.source}";

  volumeToCompose =
    appName: volume:
    let
      source =
        if volume.type == "bind" then
          resolveBindSource appName volume
        else if volume.type == "library" then
          cfg.libraries.${volume.library}.path
        else
          volume.volume;
    in
    "${source}:${volume.target}${optionalString volume.readOnly ":ro"}";

  serviceNeedsIngressNetwork =
    appName: serviceName:
    let
      upstreamService = internal.effectiveExposeService appName;
    in
    upstreamService == serviceName && internal.effectiveHost appName != null;

  healthcheckToArion =
    healthcheck:
    optionalAttrs (healthcheck.test != null) (
      {
        test = healthcheck.test;
      }
      // optionalAttrs (healthcheck.interval != null) {
        interval = healthcheck.interval;
      }
      // optionalAttrs (healthcheck.timeout != null) {
        timeout = healthcheck.timeout;
      }
      // optionalAttrs (healthcheck.retries != null) {
        retries = healthcheck.retries;
      }
      // optionalAttrs (healthcheck.startPeriod != null) {
        start_period = healthcheck.startPeriod;
      }
    );

  capabilitiesToArion =
    service:
    listToAttrs (
      map (name: nameValuePair name true) service.privileges.capabilities.add
      ++ map (name: nameValuePair name false) service.privileges.capabilities.drop
    );

  ingressNetworkAttrs =
    appName:
    let
      serviceNames = builtins.attrNames (internal.enabledServicesForApp appName);
    in
    optionalAttrs
      (builtins.any (serviceName: serviceNeedsIngressNetwork appName serviceName) serviceNames)
      {
        "${cfg.ingressNetwork}" = {
          external = true;
        };
      };

  namedVolumesForApp =
    appName:
    lib.foldl' (
      acc: service:
      lib.foldl' (
        volumeAcc: volume:
        if volume.type == "volume" then
          volumeAcc
          // {
            ${volume.volume} =
              optionalAttrs volume.external {
                external = true;
              }
              // optionalAttrs (volume.engineName != null) {
                name = volume.engineName;
              };
          }
        else
          volumeAcc
      ) acc service.volumes
    ) { } (builtins.attrValues (internal.enabledServicesForApp appName));

  helperEnvironment =
    service:
    let
      isLinuxServerImage = builtins.any (prefix: hasPrefix prefix service.image) [
        "docker.io/linuxserver/"
        "ghcr.io/linuxserver/"
        "linuxserver/"
        "lscr.io/linuxserver/"
      ];
      wantsIdentity = isLinuxServerImage || service.helpers.userIds;
      wantsTimezone = isLinuxServerImage || service.helpers.timezone;
    in
    optionalAttrs wantsIdentity {
      PUID = if userUid != null then toString userUid else "1000";
      PGID = toString userGid;
    }
    // optionalAttrs wantsTimezone {
      TZ = config.time.timeZone;
    };

  serviceToArion =
    appName: serviceName: service:
    let
      environment = helperEnvironment service // service.environment;
      networks =
        optional (service.privileges.networkMode == null) "default"
        ++ optional (serviceNeedsIngressNetwork appName serviceName) cfg.ingressNetwork
        ++ lib.optionals (service ? networks) service.networks;
    in
    {
      image = service.image;
      container_name =
        internal.serviceContainerName appName (internal.enabledServicesForApp appName)
          serviceName;
      volumes = map (volumeToCompose appName) service.volumes;
      depends_on = mapAttrs (_: dep: { condition = dep.condition; }) service.dependsOn;
      healthcheck = healthcheckToArion service.healthcheck;
      capabilities = capabilitiesToArion service;
      restart = service.restart;
    }
    // optionalAttrs (environment != { }) {
      inherit environment;
    }
    // optionalAttrs (service.labels != { }) {
      labels = service.labels;
    }
    // optionalAttrs (service ? environmentFiles && service.environmentFiles != [ ]) {
      env_file = map toString service.environmentFiles;
    }
    // optionalAttrs (service.command != null) {
      command = service.command;
    }
    // optionalAttrs (service.entrypoint != null) {
      entrypoint = service.entrypoint;
    }
    // optionalAttrs (service ? ports && service.ports != [ ]) {
      ports = service.ports;
    }
    // optionalAttrs (service.port != null) {
      expose = [ (toString service.port) ];
    }
    // optionalAttrs (service.runtime.user != null) {
      user = service.runtime.user;
    }
    // optionalAttrs (service.privileges.networkMode != null) {
      network_mode = service.privileges.networkMode;
    }
    // optionalAttrs service.privileges.privileged {
      privileged = true;
    }
    // optionalAttrs (service.privileges.devices != [ ]) {
      devices = service.privileges.devices;
    }
    // optionalAttrs (networks != [ ]) {
      inherit networks;
    };
in
{
  config = mkIf cfg.enable {
    virtualisation.arion.projects = mapAttrs' (
      appName: _:
      nameValuePair (internal.appProjectName appName) {
        settings = {
          project.name = internal.appProjectName appName;
          services = mapAttrs (serviceName: service: {
            service = serviceToArion appName serviceName service;
            out.service = {
              logging.driver = "journald";
            }
            // service.extraServiceConfig;
          }) (internal.enabledServicesForApp appName);
          networks = ingressNetworkAttrs appName;
          docker-compose.volumes = namedVolumesForApp appName;
        };
      }
    ) internal.enabledApps;
  };
}
