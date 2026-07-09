{ cfg, lib }:
let
  normalizeName = name: lib.replaceStrings [ "_" ] [ "-" ] name;
in
{
  appProjectName = appName: normalizeName appName;

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
}
