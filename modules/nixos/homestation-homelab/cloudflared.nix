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
    nameValuePair
    ;

  cfg = config.homestation.homelab;
  homelab-lib = import ./lib.nix { inherit cfg lib; };
  inherit (homelab-lib) effectiveHost;

  enabledApps = filterAttrs (_: app: app.enable) cfg.apps;

  tunnelContainers = builtins.listToAttrs (
    concatMap (
      appName:
      let
        containers = filterAttrs (
          _: container:
          container.enable
          && container.edge.enable
          && container.expose.mode == "tunnel"
          && effectiveHost container != null
        ) enabledApps.${appName}.containers;
      in
      map (
        containerName: nameValuePair (effectiveHost containers.${containerName}) "http://localhost:80"
      ) (builtins.attrNames containers)
    ) (builtins.attrNames enabledApps)
  );
in
{
  config =
    mkIf
      (
        cfg.enable && cfg.cloudflared.enable && cfg.cloudflared.tunnelId != null && tunnelContainers != { }
      )
      {
        services.cloudflared.tunnels.${cfg.cloudflared.tunnelId}.ingress = tunnelContainers;
      };
}
