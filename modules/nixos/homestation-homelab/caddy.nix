{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    concatMap
    concatStringsSep
    mkIf
    nameValuePair
    ;

  cfg = config.homestation.homelab;
  homelab-lib = import ./lib.nix { inherit cfg lib; };
  inherit (homelab-lib) containerAttrName effectiveHost enabledApps;

  exposedHttpContainers = builtins.listToAttrs (
    concatMap (
      appName:
      let
        app = enabledApps.${appName};
        containers = lib.filterAttrs (
          _: container:
          container.enable
          && container.edge.enable
          && container.caddy.enable
          && container.expose.mode != "none"
          && effectiveHost container != null
        ) app.containers;
      in
      map (
        containerName:
        nameValuePair (containerAttrName appName containerName containers.${containerName}) {
          container = containers.${containerName};
          host = effectiveHost containers.${containerName};
        }
      ) (builtins.attrNames containers)
    ) (builtins.attrNames enabledApps)
  );

  hasHttpServices = exposedHttpContainers != { };
  runCaddy = cfg.caddy.enable && (cfg.caddy.enableWithoutServices || hasHttpServices);

  indentLines =
    prefix: text:
    concatStringsSep "\n" (
      map (line: prefix + line) (builtins.filter (line: line != "") (lib.splitString "\n" text))
    );

  mkReverseProxy =
    name: site:
    let
      inherit (site) container;
      upstream =
        if container.caddy.upstream != null then
          container.caddy.upstream
        else if container.expose.protocol == "https" then
          "https://${name}:${toString container.expose.port}"
        else
          "${name}:${toString container.expose.port}";
      proxyExtra = indentLines "    " container.caddy.reverseProxyExtraConfig;
    in
    if container.caddy.reverseProxyExtraConfig == "" then
      "  reverse_proxy ${upstream}"
    else
      ''
        reverse_proxy ${upstream} {
        ${proxyExtra}
        }
      '';

  mkVirtualHost = name: site: ''
    ${site.host} {
    ${indentLines "  " site.container.caddy.extraConfig}
    ${mkReverseProxy name site}
    }
  '';

  caddyfile = pkgs.writeText "homelab-Caddyfile" ''
    ${cfg.caddy.globalConfig}
    ${concatStringsSep "\n" (lib.mapAttrsToList mkVirtualHost exposedHttpContainers)}
  '';

  parsePort =
    portStr:
    let
      protoParts = lib.splitString "/" portStr;
      proto = if lib.length protoParts > 1 then lib.last protoParts else "tcp";
      segments = lib.splitString ":" (lib.head protoParts);
      hostPort = lib.toInt (lib.elemAt segments (lib.length segments - 2));
    in
    {
      inherit proto hostPort;
    };

  parsedPorts = map parsePort cfg.caddy.ports;
  firewallTCPPorts = lib.unique (map (e: e.hostPort) (lib.filter (e: e.proto == "tcp") parsedPorts));
  firewallUDPPorts = lib.unique (map (e: e.hostPort) (lib.filter (e: e.proto == "udp") parsedPorts));
in
{
  config = mkIf (cfg.enable && runCaddy) {
    networking.firewall = mkIf cfg.caddy.openFirewall {
      allowedTCPPorts = firewallTCPPorts;
      allowedUDPPorts = firewallUDPPorts;
    };

    virtualisation.oci-containers.containers."homelab-caddy" = {
      image = cfg.caddy.image;
      autoStart = true;
      ports = cfg.caddy.ports;
      environment = cfg.caddy.environment;
      environmentFiles = cfg.caddy.environmentFiles;
      volumes = [
        "${caddyfile}:/etc/caddy/Caddyfile:ro"
        "${cfg.dataDir}/caddy/data:/data"
        "${cfg.dataDir}/caddy/config:/config"
      ]
      ++ cfg.caddy.extraVolumes;
      networks = [ cfg.edgeNetwork.name ];
    };
  };
}
