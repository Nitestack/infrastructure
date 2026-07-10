{ cfg, lib }:
let
  normalizeName = name: lib.replaceStrings [ "_" ] [ "-" ] name;

  serviceContainerName =
    appName: services: serviceName:
    let
      service = services.${serviceName};
    in
    if service ? containerName && service.containerName != null then
      service.containerName
    else if builtins.length (builtins.attrNames services) == 1 then
      normalizeName appName
    else
      "${normalizeName appName}-${normalizeName serviceName}";

  effectiveHost =
    app:
    if app.expose.host == "@" then
      cfg.domain
    else if app.expose.host == null then
      null
    else if lib.hasInfix "." app.expose.host then
      app.expose.host
    else
      "${app.expose.host}.${cfg.domain}";
in
{
  appProjectName = appName: normalizeName appName;

  inherit serviceContainerName;

  # Internal Docker-network URL for direct service-to-service calls, bypassing
  # the public host/reverse proxy. Mirrors the upstream Caddy builds internally
  # (see mkReverseProxy in caddy.nix).
  serviceUrl =
    appName: serviceName:
    let
      services = cfg.apps.${appName}.services;
    in
    "http://${serviceContainerName appName services serviceName}:${
      toString services.${serviceName}.port
    }";

  inherit effectiveHost;

  # Public URL for a homelab app, derived from its own expose.host config.
  appUrl = app: "https://${effectiveHost app}";
}
