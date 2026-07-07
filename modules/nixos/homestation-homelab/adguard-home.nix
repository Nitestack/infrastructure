{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    filterAttrs
    mapAttrsToList
    mkIf
    mkAfter
    ;

  cfg = config.homestation.homelab;

  lanRecords = filterAttrs (_: record: record.visibility == "lan") cfg.dns.records;
  rewrites = mapAttrsToList (domain: record: {
    inherit domain;
    answer = record.value;
  }) lanRecords;
in
{
  config = mkIf (cfg.enable && config.services.adguardhome.enable && rewrites != [ ]) {
    services.adguardhome.settings.filtering.rewrites = mkAfter rewrites;
  };
}
