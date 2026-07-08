{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkIf
    mkAfter
    ;

  cfg = config.homestation.homelab;
in
{
  config = mkIf (
    cfg.enable && config.services.adguardhome.enable && cfg.domain != null && cfg.lanAddress != null
  ) {
    services.adguardhome.settings.filtering.rewrites = mkAfter [
      {
        domain = "*.${cfg.domain}";
        answer = cfg.lanAddress;
        enabled = true;
      }
    ];
  };
}
