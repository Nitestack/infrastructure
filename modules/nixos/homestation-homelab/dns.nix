{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkIf
    mkMerge
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
          internal.enabledApps.${appName}.expose.mode != "none" && internal.effectiveHost appName != null
        ) (builtins.attrNames internal.enabledApps)
      )
  );
in
{
  config = mkIf cfg.enable {
    homestation.homelab.dns.records = mkMerge [
      (lib.mkOptionDefault generatedRecords)
    ];
  };
}
