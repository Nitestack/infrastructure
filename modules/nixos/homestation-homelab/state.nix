{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    attrNames
    concatMap
    filter
    hasPrefix
    mkIf
    unique
    ;

  cfg = config.homestation.homelab;
  internal = cfg._internal;

  enabledServicesWithApp = concatMap (
    appName:
    let
      services = internal.enabledServicesForApp appName;
    in
    map (serviceName: {
      inherit appName;
      service = services.${serviceName};
    }) (attrNames services)
  ) (attrNames internal.enabledApps);

  isRelativeBindSource =
    volume: volume.type == "bind" && volume.source != null && !hasPrefix "/" volume.source;

  # A volume that needs a tmpfiles rule: explicit hostPath.enable, OR an implicit relative bind source
  needsTmpfiles =
    volume: volume.type == "bind" && (volume.hostPath.enable || isRelativeBindSource volume);

  resolveBindSource =
    appName: volume:
    if isRelativeBindSource volume then "${cfg.dataDir}/${appName}/${volume.source}" else volume.source;

  volumeRules = concatMap (
    { appName, service }:
    map (
      volume:
      let
        entryType = if volume.hostPath.type == "file" then "f" else "d";
        source = resolveBindSource appName volume;
      in
      "${entryType} ${source} ${volume.hostPath.mode} ${volume.hostPath.user} ${volume.hostPath.group} -"
    ) (filter needsTmpfiles service.volumes)
  ) enabledServicesWithApp;

  # Per-app base dirs — created whenever an app has at least one relative bind-source volume
  appsWithRelativeVolumes = unique (
    concatMap (
      { appName, service }:
      if builtins.any isRelativeBindSource service.volumes then [ appName ] else [ ]
    ) enabledServicesWithApp
  );

  appBaseDirRules = map (
    appName: "d ${cfg.dataDir}/${appName} 0755 root root -"
  ) appsWithRelativeVolumes;

  # Library dirs — only created when library.create = true
  libraryRules = concatMap (
    libraryName:
    let
      library = cfg.libraries.${libraryName};
    in
    if library.create then
      [ "d ${library.path} ${library.mode} ${library.user} ${library.group} -" ]
    else
      [ ]
  ) (attrNames cfg.libraries);
in
{
  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = unique (
      [
        "d ${cfg.dataDir} 0755 root root -"
        "d ${cfg.dataDir}/caddy 0755 root root -"
        "d ${cfg.dataDir}/caddy/data 0755 root root -"
        "d ${cfg.dataDir}/caddy/config 0755 root root -"
      ]
      ++ appBaseDirRules
      ++ volumeRules
      ++ libraryRules
    );
  };
}
