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

  # Eligible for the shared *.${cfg.domain} wildcard block: hosts that are
  # exactly one label under cfg.domain. A Let's Encrypt wildcard cert never
  # covers the bare apex (expose.host = "@") or a fully custom foreign host
  # (expose.host containing a dot), so those keep their own top-level block.
  isWildcardHost =
    host:
    cfg.domain != null
    && host != null
    && host != cfg.domain
    && lib.hasSuffix ".${cfg.domain}" host
    && lib.length (lib.splitString "." host) == lib.length (lib.splitString "." cfg.domain) + 1;

  wildcardAppNames = filter (
    appName: isWildcardHost (internal.effectiveHost appName)
  ) exposedAppNames;
  otherAppNames = filter (appName: !isWildcardHost (internal.effectiveHost appName)) exposedAppNames;

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

  appBody =
    appName:
    concatStringsSep "\n" (
      imap0 (routeIndex: route: indentLines "  " (mkRoute appName routeIndex route)) (
        internal.resolvedRoutesForApp appName
      )
    );

  mkVirtualHost = appName: ''
    ${internal.effectiveHost appName} {
    ${appBody appName}
    }
  '';

  mkAppHandle =
    appName:
    let
      matcherName = lib.replaceStrings [ "_" ] [ "-" ] appName;
    in
    ''
      @${matcherName} host ${internal.effectiveHost appName}
      handle @${matcherName} {
      ${appBody appName}
      }
    '';

  wildcardBlockBody = concatStringsSep "\n" (
    map (appName: indentLines "  " (mkAppHandle appName)) wildcardAppNames
    ++ lib.optional (cfg.caddy.extraSiteBlocks != "") (indentLines "  " cfg.caddy.extraSiteBlocks)
  );

  wildcardBlock =
    if cfg.domain != null && (wildcardAppNames != [ ] || cfg.caddy.extraSiteBlocks != "") then
      ''
        *.${cfg.domain} {
        ${wildcardBlockBody}
        }
      ''
    else
      "";

  caddyfile = pkgs.writeText "homelab-Caddyfile" ''
    ${cfg.caddy.globalConfig}
    ${wildcardBlock}
    ${concatStringsSep "\n" (map mkVirtualHost otherAppNames)}
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
  config = mkIf (cfg.enable && cfg.caddy.enable) {
    homestation.homelab.caddy = {
      # pre-built Caddy image with the caddy-dns/cloudflare plugin, so
      # automatic HTTPS works via DNS-01 for hostnames that are only
      # privately resolvable (LAN/Tailnet), not just publicly reachable ones
      image = lib.mkDefault "caddybuilds/caddy-cloudflare:2.11.4@sha256:62639363ceb043393da9c3895d7c97a9a49ccf840bea0cc7e6479465d12ade96";
      globalConfig = lib.mkDefault ''
        {
          acme_dns cloudflare {env.CLOUDFLARE_API_TOKEN}
        }
      '';
      environmentFiles = lib.mkDefault (
        lib.optional (
          config ? sops && config.sops.templates ? "caddy.env"
        ) config.sops.templates."caddy.env".path
      );
    };

    systemd.services.${config.virtualisation.oci-containers.containers."caddy".serviceName} = {
      requires = [ "homelab-network.service" ];
      after = [ "homelab-network.service" ];
    };

    networking.firewall = mkIf cfg.caddy.openFirewall {
      allowedTCPPorts = firewallTCPPorts;
      allowedUDPPorts = firewallUDPPorts;
    };

    virtualisation.oci-containers.containers."caddy" = {
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
