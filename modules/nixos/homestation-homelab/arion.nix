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

  resolveBindSource =
    appName: volume:
    if hasPrefix "/" volume.source then volume.source else "${cfg.dataDir}/${appName}/${volume.source}";

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

  serviceToArion =
    appName: serviceName: service:
    let
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
    }
    // optionalAttrs (service ? environment && service.environment != { }) {
      environment = service.environment;
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
    // optionalAttrs (service.port != null) {
      expose = [ (toString service.port) ];
    }
    // optionalAttrs (service.runtime.user != null) {
      user = service.runtime.user;
    }
    // optionalAttrs (service.runtime.workingDir != null) {
      working_dir = service.runtime.workingDir;
    }
    // optionalAttrs (service.runtime.tmpfs != [ ]) {
      tmpfs = service.runtime.tmpfs;
    }
    // optionalAttrs service.runtime.tty {
      tty = true;
    }
    // optionalAttrs (service.runtime.stopGracePeriod != null) {
      stop_grace_period = service.runtime.stopGracePeriod;
    }
    // optionalAttrs (service.runtime.stopSignal != null) {
      stop_signal = service.runtime.stopSignal;
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
    // optionalAttrs (service.privileges.dns != [ ]) {
      dns = service.privileges.dns;
    }
    // optionalAttrs (service.privileges.extraHosts != [ ]) {
      extra_hosts = service.privileges.extraHosts;
    }
    // optionalAttrs (service.privileges.sysctls != { }) {
      sysctls = service.privileges.sysctls;
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
          }) (internal.enabledServicesForApp appName);
          networks = edgeNetworkAttrs appName;
        };
      }
    ) internal.enabledApps;
  };
}
