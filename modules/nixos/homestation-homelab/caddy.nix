{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    concatStringsSep
    filter
    imap0
    mapAttrsToList
    mkIf
    optionalString
    ;

  cfg = config.homestation.homelab;
  internal = cfg._internal;

  exposedAppNames = filter (
    appName:
    internal.enabledApps.${appName}.expose.mode != "none"
    && internal.effectiveHost appName != null
    && internal.resolvedRoutesForApp appName != [ ]
  ) (builtins.attrNames internal.enabledApps);

  hasHttpServices = exposedAppNames != [ ];
  runCaddy = cfg.caddy.enable && (cfg.caddy.enableWithoutServices || hasHttpServices);

  indentLines =
    prefix: text:
    concatStringsSep "\n" (
      map (line: prefix + line) (builtins.filter (line: line != "") (lib.splitString "\n" text))
    );

  mkMatcher =
    appName: routeIndex: route:
    let
      matcherName = "route-${lib.replaceStrings [ "_" ] [ "-" ] appName}-${toString routeIndex}";
      hasMatcher = route.match.path != [ ] || route.match.not.path != [ ];
      matcherBody = concatStringsSep "\n" (
        lib.optional (route.match.path != [ ]) "path ${concatStringsSep " " route.match.path}"
        ++ lib.optional (
          route.match.not.path != [ ]
        ) "not path ${concatStringsSep " " route.match.not.path}"
      );
    in
    {
      inherit hasMatcher matcherName;
      block =
        if hasMatcher then
          ''
            @${matcherName} {
              ${matcherBody}
            }
          ''
        else
          "";
    };

  mkReverseProxy =
    appName: route:
    let
      app = internal.enabledApps.${appName};
      enabledServices = internal.enabledServicesForApp appName;
      service = enabledServices.${route.upstream.service};
      upstreamHost = internal.serviceContainerName appName enabledServices route.upstream.service;
      upstream =
        if app.expose.protocol == "https" then
          "https://${upstreamHost}:${toString service.port}"
        else
          "${upstreamHost}:${toString service.port}";
      proxyHeaders = concatStringsSep "\n" (
        mapAttrsToList (name: value: "  header_up ${name} ${value}") route.proxy.headers.request
      );
      transportConfig = concatStringsSep "\n" (
        mapAttrsToList (name: value: if value then "    ${name}" else "") route.proxy.transport.http
      );
    in
    if route.proxy.headers.request == { } && route.proxy.transport.http == { } then
      "reverse_proxy ${upstream}"
    else
      ''
        reverse_proxy ${upstream} {
        ${optionalString (route.proxy.headers.request != { }) proxyHeaders}
        ${optionalString (route.proxy.transport.http != { }) ''
            transport http {
          ${transportConfig}
            }
        ''}
        }
      '';

  mkRoute =
    appName: routeIndex: route:
    let
      matcher = mkMatcher appName routeIndex route;
      body = concatStringsSep "\n" (
        lib.optional (route.requestBody.maxSize != null) ''
          request_body {
            max_size ${route.requestBody.maxSize}
          }
        ''
        ++ lib.optional (route.encode != [ ]) "encode ${concatStringsSep " " route.encode}"
        ++ [ (mkReverseProxy appName route) ]
        ++ lib.optional (route.extraConfig != "") route.extraConfig
      );
    in
    concatStringsSep "\n" (
      lib.optional matcher.hasMatcher matcher.block
      ++ [
        (
          if matcher.hasMatcher then
            ''
              handle @${matcher.matcherName} {
              ${indentLines "  " body}
              }
            ''
          else
            ''
              handle {
              ${indentLines "  " body}
              }
            ''
        )
      ]
    );

  mkVirtualHost = appName: ''
    ${internal.effectiveHost appName} {
    ${concatStringsSep "\n" (
      imap0 (routeIndex: route: indentLines "  " (mkRoute appName routeIndex route)) (
        internal.resolvedRoutesForApp appName
      )
    )}
    }
  '';

  caddyfile = pkgs.writeText "homelab-Caddyfile" ''
    ${cfg.caddy.globalConfig}
    ${concatStringsSep "\n" (map mkVirtualHost exposedAppNames)}
    ${cfg.caddy.extraSiteBlocks}
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
    systemd.services.${config.virtualisation.oci-containers.containers."homelab-caddy".serviceName} = {
      requires = [ "homelab-network.service" ];
      after = [ "homelab-network.service" ];
    };

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
