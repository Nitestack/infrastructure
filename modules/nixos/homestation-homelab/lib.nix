{ cfg, lib }:
let
  enabledApps = lib.filterAttrs (_: app: app.enable) cfg.apps;
in
{
  inherit enabledApps;

  enabledContainersForApp =
    appName: lib.filterAttrs (_: container: container.enable) enabledApps.${appName}.containers;

  appNetworkName = appName: "${cfg.network.prefix}-${appName}";

  containerAttrName =
    appName: containerName: container:
    if container.docker.name != null then container.docker.name else "${appName}-${containerName}";

  effectiveHost =
    container:
    if container.expose.apexDomain then
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
