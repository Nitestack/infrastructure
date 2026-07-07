{
  config,
  lib,
  ...
}:
let
  inherit (lib) filter mkIf;

  cfg = config.homestation.homelab;
  internal = cfg._internal;
  publicApps = filter (
    appName:
    internal.enabledApps.${appName}.expose.mode == "public" && internal.effectiveHost appName != null
  ) (builtins.attrNames internal.enabledApps);

  wildcardEntries =
    if cfg.cloudflared.wildcardIngress && cfg.domain != null && publicApps != [ ] then
      {
        "*.${cfg.domain}" = "http://localhost:80";
        "${cfg.domain}" = "http://localhost:80";
      }
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
