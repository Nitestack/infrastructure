{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkIf
    nameValuePair
    ;

  cfg = config.homestation.homelab;
  internal = cfg._internal;

  generatedRecords = builtins.listToAttrs (
    map
      (
        appName:
        nameValuePair (internal.effectiveHost appName) {
          type = "A";
          value = cfg.lanAddress;
          visibility = "lan";
        }
      )
      (
        lib.filter (
          appName:
          cfg.lanAddress != null
          && internal.enabledApps.${appName}.expose.mode != "none"
          && internal.effectiveHost appName != null
        ) (builtins.attrNames internal.enabledApps)
      )
  );
in
{
  config = mkIf cfg.enable {
    homestation.homelab.dns.records = lib.mapAttrs (_: record: lib.mkDefault record) generatedRecords;
  };
}
