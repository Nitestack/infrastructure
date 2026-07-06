{ cfg, lib }:
let
  normalizeContainerName = name: lib.replaceStrings [ "_" ] [ "-" ] name;

  normalizedApps = lib.mapAttrs (
    _: app:
    app
    // {
      containers =
        if app.container != null then app.containers // { main = app.container; } else app.containers;
    }
  ) cfg.apps;

  appContainers = appName: normalizedApps.${appName}.containers;

  enabledApps = lib.filterAttrs (_: app: app.enable) normalizedApps;
in
{
  inherit enabledApps normalizedApps;
  inherit appContainers;

  enabledContainersForApp =
    appName: lib.filterAttrs (_: container: container.enable) (appContainers appName);

  appNetworkName = appName: "${cfg.network.prefix}-${appName}";

  containerAttrName =
    appName: containerName: container:
    if container.name != null then
      container.name
    else if builtins.length (builtins.attrNames (appContainers appName)) == 1 then
      normalizeContainerName appName
    else
      "${normalizeContainerName appName}-${normalizeContainerName containerName}";

  effectiveHost =
    container:
    if container.expose.host == "@" then
      cfg.domain
    else if container.expose.host == null then
      null
    else if lib.hasInfix "." container.expose.host then
      container.expose.host
    else if cfg.domain != null then
      "${container.expose.host}.${cfg.domain}"
    else
      container.expose.host;
}
