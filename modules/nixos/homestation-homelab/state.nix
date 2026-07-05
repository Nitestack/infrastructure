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
    filterAttrs
    hasPrefix
    mkIf
    unique
    ;

  cfg = config.homestation.homelab;

  enabledApps = filterAttrs (_: app: app.enable) cfg.apps;

  enabledContainersWithApp = concatMap (
    appName:
    let
      containers = filterAttrs (_: container: container.enable) enabledApps.${appName}.containers;
    in
    map (containerName: {
      inherit appName;
      container = containers.${containerName};
    }) (attrNames containers)
  ) (attrNames enabledApps);

  isRelativeSource = volume: volume.source != null && !hasPrefix "/" volume.source;

  # A volume that needs a tmpfiles rule: explicit hostPath.enable, OR an implicit relative source
  needsTmpfiles =
    volume: volume.library == null && (volume.hostPath.enable || isRelativeSource volume);

  resolveSource =
    appName: volume:
    if isRelativeSource volume then "${cfg.dataDir}/${appName}/${volume.source}" else volume.source;

  volumeRules = concatMap (
    { appName, container }:
    map (
      volume:
      let
        entryType = if volume.hostPath.type == "file" then "f" else "d";
        source = resolveSource appName volume;
      in
      "${entryType} ${source} ${volume.hostPath.mode} ${volume.hostPath.user} ${volume.hostPath.group} -"
    ) (filter needsTmpfiles container.volumes)
  ) enabledContainersWithApp;

  # Per-app base dirs — created whenever an app has at least one relative-source volume
  appsWithRelativeVolumes = unique (
    concatMap (
      { appName, container }:
      if builtins.any isRelativeSource container.volumes then [ appName ] else [ ]
    ) enabledContainersWithApp
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
