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
    if container.docker.name != null then
      container.docker.name
    else
      "${appName}-${containerName}";

  effectiveHost =
    container:
    if container.expose.host != null then
      container.expose.host
    else if container.expose.subdomain != null && cfg.domain != null then
      if container.expose.subdomain == "" then cfg.domain else "${container.expose.subdomain}.${cfg.domain}"
    else
      null;
}
