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

  # Send tunnel traffic to Caddy's HTTPS listener. cloudflared can't know the
  # real requested hostname when picking a TLS SNI for one wildcard ingress
  # rule, so it's pinned to a fixed name that Caddy's *.${cfg.domain}
  # wildcard certificate covers (see caddy.nix). noTLSVerify stays on since
  # cloudflared never validates that this placeholder SNI matches anything;
  # it only needs the handshake to succeed.
  originConfig = {
    service = "https://localhost:443";
    originRequest = {
      noTLSVerify = true;
      originServerName = "_cloudflared.${cfg.domain}";
    };
  };

  wildcardEntries =
    if cfg.cloudflared.wildcardIngress && cfg.domain != null && publicApps != [ ] then
      {
        "*.${cfg.domain}" = originConfig;
      }
      // lib.optionalAttrs exposeApex { "${cfg.domain}" = originConfig; }
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
