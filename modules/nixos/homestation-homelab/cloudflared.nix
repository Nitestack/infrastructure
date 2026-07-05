{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.homestation.homelab;

  wildcardEntries =
    if cfg.cloudflared.wildcardIngress && cfg.domain != null then
      {
        "*.${cfg.domain}" = "http://localhost:80";
        "${cfg.domain}" = "http://localhost:80";
      }
    else
      { };
in
{
  config = mkIf (
    cfg.enable
    && cfg.cloudflared.enable
    && cfg.cloudflared.tunnelId != null
    && wildcardEntries != { }
  ) {
    services.cloudflared.tunnels.${cfg.cloudflared.tunnelId}.ingress = wildcardEntries;
  };
}
