{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    concatMap
    filter
    filterAttrs
    hasPrefix
    mkIf
    unique
    ;

  cfg = config.homestation.homelab;

  enabledApps = filterAttrs (_: app: app.enable) cfg.apps;

  enabledContainers = concatMap (
    appName:
    let
      containers = filterAttrs (_: container: container.enable) enabledApps.${appName}.containers;
    in
    map (containerName: containers.${containerName}) (builtins.attrNames containers)
  ) (builtins.attrNames enabledApps);

  managedVolume =
    volume:
    volume.hostPath.enable || volume.source == cfg.dataDir || hasPrefix "${cfg.dataDir}/" volume.source;

  volumeRules = concatMap (
    container:
    map (
      volume:
      let
        entryType = if volume.hostPath.type == "file" then "f" else "d";
      in
      "${entryType} ${volume.source} ${volume.hostPath.mode} ${volume.hostPath.user} ${volume.hostPath.group} -"
    ) (filter managedVolume container.volumes)
  ) enabledContainers;
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
      ++ volumeRules
    );
  };
}
