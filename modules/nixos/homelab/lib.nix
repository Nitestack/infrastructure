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

  isRelativeBindSource =
    volume: volume.type == "bind" && volume.source != null && !lib.hasPrefix "/" volume.source;

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
  inherit normalizeName;

  appProjectName = appName: normalizeName appName;

  inherit serviceContainerName;

  inherit isRelativeBindSource;

  # Resolves a bind-mount `source` (relative or absolute) to the path Arion
  # and tmpfiles rules should use. Relative sources are rooted under the
  # app's directory inside `cfg.dataDir`; absolute sources pass through
  # unchanged. validation.nix already rejects a null `source` on any enabled
  # bind volume, so the throw here is a fallback with a readable message
  # rather than a `hasPrefix` type error.
  resolveBindSource =
    appName: source:
    if source == null then
      throw "bind volume for app '${appName}' has null source (validation should have caught this)"
    else if lib.hasPrefix "/" source then
      source
    else
      "${cfg.dataDir}/${appName}/${source}";

  # Builds an env-var attrset from `homelab.smtp`, using whatever variable
  # names the target app expects (they differ per app, so callers name
  # only the fields they need). Passes `security` through unmapped — use
  # `smtpSecurityMapped` when an app needs a different vocabulary.
  smtpEnv =
    {
      hostVar ? null,
      portVar ? null,
      fromVar ? null,
      usernameVar ? null,
      securityVar ? null,
    }:
    builtins.listToAttrs (
      lib.filter (e: e.name != null) [
        {
          name = hostVar;
          value = cfg.smtp.host;
        }
        {
          name = portVar;
          value = toString cfg.smtp.port;
        }
        {
          name = fromVar;
          value = cfg.smtp.from;
        }
        {
          name = usernameVar;
          value = cfg.smtp.username;
        }
        {
          name = securityVar;
          value = cfg.smtp.security;
        }
      ]
    );

  # Translates `homelab.smtp.security` ("starttls"/"force_tls"/"off") into
  # whatever vocabulary a specific app's SMTP integration expects (a string,
  # or "True"/"False" for boolean-flag-style configs).
  smtpSecurityMapped =
    {
      starttls,
      forceTls,
      off,
    }:
    {
      inherit starttls off;
      force_tls = forceTls;
    }
    .${cfg.smtp.security};

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
