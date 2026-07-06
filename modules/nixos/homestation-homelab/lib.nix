{ cfg, lib }:
let
  normalizeName = name: lib.replaceStrings [ "_" ] [ "-" ] name;
in
{
  appProjectName = appName: "${cfg.network.prefix}-${normalizeName appName}";

  serviceContainerName =
    appName: serviceName: service:
    if service.name != null then
      service.name
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
    else if cfg.domain != null then
      "${app.expose.host}.${cfg.domain}"
    else
      app.expose.host;
}
