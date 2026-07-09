{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    filter
    mkIf
    ;

  cfg = config.homestation.homelab;
  internal = cfg._internal;
  wildcardIngress = builtins.any (app: app.expose.mode == "public") (
    builtins.attrValues internal.enabledApps
  );
  publicApps = filter (
    appName:
    internal.enabledApps.${appName}.expose.mode == "public" && internal.effectiveHost appName != null
  ) (builtins.attrNames internal.enabledApps);
  exposeApex = builtins.any (appName: internal.effectiveHost appName == cfg.domain) publicApps;

  originConfig = {
    service = "http://127.0.0.1:${toString cfg.caddy.tunnelPort}";
  };

  wildcardEntries =
    if wildcardIngress && publicApps != [ ] then
      {
        "*.${cfg.domain}" = originConfig;
      }
      // lib.optionalAttrs exposeApex { "${cfg.domain}" = originConfig; }
    else
      { };
in
{
  config =
    mkIf
      (cfg.enable && cfg.cloudflared.enable && cfg.cloudflared.tunnelId != null && wildcardEntries != { })
      {
        services.cloudflared.tunnels.${cfg.cloudflared.tunnelId}.ingress = wildcardEntries;
      };
}
