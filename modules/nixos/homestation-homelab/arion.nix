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
          cfg.libraries.${volume.name}.path
        else
          volume.name;
    in
    "${source}:${volume.target}${optionalString volume.readOnly ":ro"}";

  serviceNeedsEdgeNetwork =
    appName: serviceName:
    let
      app = internal.enabledApps.${appName};
      routes = internal.resolvedRoutesForApp appName;
    in
    (
      app.expose.mode != "none"
      && app.expose.service == serviceName
      && internal.effectiveHost appName != null
    )
    || builtins.any (
      route: route.upstream.service == serviceName && internal.effectiveHost appName != null
    ) routes;

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

  edgeNetworkAttrs =
    appName:
    let
      serviceNames = builtins.attrNames (internal.enabledServicesForApp appName);
    in
    optionalAttrs (builtins.any (serviceName: serviceNeedsEdgeNetwork appName serviceName) serviceNames)
      {
        "${cfg.edgeNetwork.name}" = {
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
            ${volume.name} =
              optionalAttrs volume.external {
                external = true;
              }
              // optionalAttrs (volume.dockerName != null) {
                name = volume.dockerName;
              };
          }
        else
          volumeAcc
      ) acc service.volumes
    ) { } (builtins.attrValues (internal.enabledServicesForApp appName));

  helperEnvironment =
    service:
    let
      wantsIdentity = service.helpers.linuxserver || service.helpers.identity;
      wantsTimezone = service.helpers.linuxserver || service.helpers.timezone;
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
        ++ optional (serviceNeedsEdgeNetwork appName serviceName) cfg.edgeNetwork.name
        ++ lib.optionals (service ? networks) service.networks;
    in
    {
      image = service.image;
      container_name = internal.serviceContainerName appName serviceName service;
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
    }
    // optionalAttrs (cfg.logging.driver != null) {
      logging = {
        driver = cfg.logging.driver;
      }
      // optionalAttrs (cfg.logging.options != { }) {
        options = cfg.logging.options;
      };
    }
    // service.extraServiceConfig;
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
          }) (internal.enabledServicesForApp appName);
          networks = edgeNetworkAttrs appName;
          docker-compose.volumes = namedVolumesForApp appName;
        };
      }
    ) internal.enabledApps;
  };
}
