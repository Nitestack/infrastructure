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
    mapAttrsToList
    mkIf
    unique
    ;

  cfg = config.homelab;
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

  inherit (cfg.lib) isRelativeBindSource;

  volumeRules = concatMap (
    { appName, service }:
    map (
      volume:
      let
        source = cfg.lib.resolveBindSource appName volume.source;
      in
      "d ${source} ${volume.mode} ${volume.owner} ${volume.group} -"
    ) (filter isRelativeBindSource service.volumes)
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

  libraryRules = mapAttrsToList (
    _: library: "d ${library.path} ${library.mode} ${library.owner} ${library.group} -"
  ) cfg.libraries;

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
