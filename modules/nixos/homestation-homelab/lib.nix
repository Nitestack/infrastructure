{ cfg, lib }:
let
  normalizeName = name: lib.replaceStrings [ "_" ] [ "-" ] name;
  normalizedApps = lib.mapAttrs (_: app: app // { containers = app.services; }) cfg.apps;
  appContainers = appName: normalizedApps.${appName}.containers;
  enabledApps = lib.filterAttrs (_: app: app.enable) normalizedApps;
in
{
  inherit normalizedApps enabledApps appContainers;

  enabledContainersForApp =
    appName: lib.filterAttrs (_: container: container.enable) (appContainers appName);

  appNetworkName = appName: "${cfg.network.prefix}-${appName}";

  appProjectName = appName: "${cfg.network.prefix}-${normalizeName appName}";

  containerAttrName =
    appName: containerName: container:
    if container ? name && container.name != null then
      container.name
    else if builtins.length (builtins.attrNames (appContainers appName)) == 1 then
      normalizeName appName
    else
      "${normalizeName appName}-${normalizeName containerName}";

  serviceContainerName =
    appName: serviceName: _service:
    "${normalizeName appName}-${normalizeName serviceName}";

  effectiveHost =
    app:
    if app.expose.host == "@" then
      cfg.domain
    else if app.expose.host == null then
      null
    else if lib.hasInfix "." app.expose.host then
      app.expose.host
    else if cfg.domain != null then
      "${app.expose.host}.${cfg.domain}"
    else
      app.expose.host;
}
