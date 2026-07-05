{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    concatMap
    filterAttrs
    mkIf
    mkMerge
    nameValuePair
    ;

  cfg = config.homestation.homelab;
  homelab-lib = import ./lib.nix { inherit cfg lib; };
  inherit (homelab-lib) effectiveHost enabledApps enabledContainersForApp;

  generatedRecords = builtins.listToAttrs (
    concatMap (
      appName:
      let
        containers = filterAttrs (
          _: container:
          container.enable
          && container.edge.enable
          && container.dns.enable
          && effectiveHost container != null
          && (container.expose.mode == "private" || container.expose.mode == "public")
        ) enabledApps.${appName}.containers;
      in
      map (
        containerName:
        nameValuePair (effectiveHost containers.${containerName}) {
          type = "A";
          value = cfg.lanAddress;
          visibility = "lan";
        }
      ) (builtins.attrNames containers)
    ) (builtins.attrNames enabledApps)
  );

  containerRecords = concatMap (
    appName:
    let
      containers = enabledContainersForApp appName;
    in
    map (containerName: containers.${containerName}.dns.records) (builtins.attrNames containers)
  ) (builtins.attrNames enabledApps);
in
{
  config = mkIf cfg.enable {
    homestation.homelab.dns.records = mkMerge ([ generatedRecords ] ++ containerRecords);
  };
}
