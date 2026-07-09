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

  cfg = config.homelab;
in
{
  config = mkIf (cfg.enable && config.services.adguardhome.enable) {
    services.adguardhome.settings.filtering.rewrites = mkAfter [
      {
        domain = "*.${cfg.domain}";
        answer = cfg.lanAddress;
        enabled = true;
      }
    ];
  };
}
