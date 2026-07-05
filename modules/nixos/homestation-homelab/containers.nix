{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    attrValues
    concatMap
    listToAttrs
    mkIf
    nameValuePair
    optionalAttrs
    optionalString
    ;

  cfg = config.homestation.homelab;
  homelab-lib = import ./lib.nix { inherit cfg lib; };
  inherit (homelab-lib)
    appNetworkName
    containerAttrName
    enabledApps
    enabledContainersForApp
    ;

  resolveVolumeSource =
    appName: volume:
    if volume.library != null then
      cfg.libraries.${volume.library}.path
    else if volume.source != null && !lib.hasPrefix "/" volume.source then
      "${cfg.dataDir}/${appName}/${volume.source}"
    else
      volume.source;

  volumeToString =
    appName: volume:
    let
      source = resolveVolumeSource appName volume;
    in
    "${source}:${volume.target}${optionalString volume.readOnly ":ro"}";

  listenerToPort =
    listener:
    let
      prefix = optionalString (listener.bind != null) "${listener.bind}:";
      suffix = optionalString (listener.protocol != "tcp") "/${listener.protocol}";
    in
    "${prefix}${toString listener.hostPort}:${toString listener.containerPort}${suffix}";

  containerToOci =
    appName: containerName: container:
    let
      enabledDeps = enabledContainersForApp appName;
      enabledDependencyNames = builtins.filter (
        dep: builtins.hasAttr dep enabledDeps
      ) container.dependsOn;
      networks =
        lib.optional (builtins.length (builtins.attrNames enabledDeps) > 1) (appNetworkName appName)
        ++ lib.optional container.edge.enable cfg.edgeNetwork.name
        ++ container.networks;
    in
    {
      image = container.image;
      autoStart = container.docker.autoStart;
      environment = container.env;
      environmentFiles = container.environmentFiles;
      volumes = map (volumeToString appName) container.volumes;
      ports = map listenerToPort (attrValues container.listeners);
      dependsOn = map (dep: containerAttrName appName dep enabledDeps.${dep}) enabledDependencyNames;
      inherit networks;
      labels = container.docker.labels;
      extraOptions = container.docker.extraOptions;
    }
    // optionalAttrs (container.command != null) {
      cmd = container.command;
    }
    // optionalAttrs (container.entrypoint != null) {
      entrypoint = container.entrypoint;
    };

  enabledContainers = listToAttrs (
    concatMap (
      appName:
      let
        containers = enabledContainersForApp appName;
      in
      map (
        containerName:
        nameValuePair (containerAttrName appName containerName containers.${containerName}) (
          containerToOci appName containerName containers.${containerName}
        )
      ) (builtins.attrNames containers)
    ) (builtins.attrNames enabledApps)
  );
in
{
  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers = enabledContainers;
  };
}
