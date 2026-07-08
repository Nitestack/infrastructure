{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    filter
    mkIf
    mkMerge
    mkDefault
    ;

  cfg = config.homestation.homelab;
  internal = cfg._internal;
  publicApps = filter (
    appName:
    internal.enabledApps.${appName}.expose.mode == "public" && internal.effectiveHost appName != null
  ) (builtins.attrNames internal.enabledApps);
  exposeApex =
    cfg.domain != null
    && builtins.any (appName: internal.effectiveHost appName == cfg.domain) publicApps;

  wildcardEntries =
    if cfg.cloudflared.wildcardIngress && cfg.domain != null && publicApps != [ ] then
      {
        # Send tunnel traffic to Caddy's HTTPS listener. Pointing the tunnel at
        # localhost:80 causes redirect loops because Caddy auto-upgrades these
        # hostnames to HTTPS while the client is already on HTTPS at Cloudflare.
        "*.${cfg.domain}" = {
          service = "https://localhost:443";
          originRequest.noTLSVerify = true;
        };
      }
      // lib.optionalAttrs exposeApex {
        "${cfg.domain}" = {
          service = "https://localhost:443";
          originRequest.noTLSVerify = true;
        };
      }
    else
      { };
in
{
  config = mkMerge [
    {
      homestation.homelab.cloudflared.wildcardIngress = mkDefault (
        cfg.enable
        && builtins.any (app: app.enable && app.expose.mode == "public") (builtins.attrValues cfg.apps)
      );
    }
    (mkIf
      (cfg.enable && cfg.cloudflared.enable && cfg.cloudflared.tunnelId != null && wildcardEntries != { })
      {
        services.cloudflared.tunnels.${cfg.cloudflared.tunnelId}.ingress = wildcardEntries;
      }
    )
  ];
}
