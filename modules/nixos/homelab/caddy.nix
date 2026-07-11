{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    any
    concatStringsSep
    filter
    mkIf
    ;

  cfg = config.homelab;
  internal = cfg._internal;
  networkUnitName = "container-edge-network";
  tunnelPort = cfg.caddy.tunnelPort;

  exposedAppNames = filter (
    appName:
    internal.enabledApps.${appName}.expose.mode != "none"
    && internal.effectiveHost appName != null
    && internal.effectiveExposeService appName != null
  ) (builtins.attrNames internal.enabledApps);

  # Eligible for the shared *.${cfg.domain} wildcard block: hosts that are
  # exactly one label under cfg.domain. A Let's Encrypt wildcard cert never
  # covers the bare apex (expose.host = "@") or a fully custom foreign host
  # (expose.host containing a dot), so those keep their own top-level block.
  isWildcardHost =
    host:
    host != null
    && host != cfg.domain
    && lib.hasSuffix ".${cfg.domain}" host
    && lib.length (lib.splitString "." host) == lib.length (lib.splitString "." cfg.domain) + 1;

  wildcardAppNames = filter (
    appName: isWildcardHost (internal.effectiveHost appName)
  ) exposedAppNames;
  otherAppNames = filter (appName: !isWildcardHost (internal.effectiveHost appName)) exposedAppNames;

  isPrivateApp = appName: internal.enabledApps.${appName}.expose.mode == "private";
  needsForbiddenSnippet = any isPrivateApp exposedAppNames || cfg.caddy.extraHosts != "";

  indentLines =
    prefix: text:
    concatStringsSep "\n" (
      map (line: prefix + line) (builtins.filter (line: line != "") (lib.splitString "\n" text))
    );

  mkReverseProxy =
    appName:
    let
      app = internal.enabledApps.${appName};
      target =
        if app.expose.targetUpstream != null then
          app.expose.targetUpstream
        else
          let
            enabledServices = internal.enabledServicesForApp appName;
            upstreamService = internal.effectiveExposeService appName;
            service = enabledServices.${upstreamService};
            upstreamHost = internal.serviceContainerName appName enabledServices upstreamService;
          in
          "${upstreamHost}:${toString service.port}";
      upstream = if app.expose.protocol == "https" then "https://${target}" else target;
    in
    "reverse_proxy ${upstream}";

  appBody =
    appName:
    let
      app = internal.enabledApps.${appName};
    in
    concatStringsSep "\n" (
      lib.optional (app.expose.caddyDirectives != "") app.expose.caddyDirectives
      ++ [ (mkReverseProxy appName) ]
    );

  forbiddenBody = ''
    import forbidden_403
    ${forbiddenAssetsHandle}
    handle {
      error 403
    }
  '';

  forbiddenAssetsHandle = ''
    handle /__403-assets__/* {
      root * /srv/errors
      file_server
    }'';

  mkEntryPointAddress =
    scheme: host:
    if scheme == "http" then "http://${host}:${toString tunnelPort}" else "https://${host}";

  mkVirtualHost =
    scheme: appName:
    let
      body = if scheme == "http" && isPrivateApp appName then forbiddenBody else appBody appName;
    in
    ''
      ${mkEntryPointAddress scheme (internal.effectiveHost appName)} {
      ${body}
      }
    '';

  mkAppHandle =
    scheme: appName:
    let
      matcherName = lib.replaceStrings [ "_" ] [ "-" ] appName;
      body =
        if scheme == "http" && isPrivateApp appName then
          ''
            handle {
              error 403
            }
          ''
        else
          appBody appName;
    in
    ''
      @${matcherName} host ${internal.effectiveHost appName}
      handle @${matcherName} {
      ${body}
      }
    '';

  mkWildcardBlock =
    scheme:
    let
      includeExtraHosts = scheme == "https" && cfg.caddy.extraHosts != "";
      body = concatStringsSep "\n" (
        lib.optional needsForbiddenSnippet "import forbidden_403"
        ++ lib.optional needsForbiddenSnippet forbiddenAssetsHandle
        ++ map (appName: indentLines "  " (mkAppHandle scheme appName)) wildcardAppNames
        ++ lib.optional includeExtraHosts (indentLines "  " cfg.caddy.extraHosts)
        ++ [
          (
            if scheme == "http" then
              ''
                handle {
                  error 403
                }
              ''
            else
              ''
                handle {
                  abort
                }
              ''
          )
        ]
      );
    in
    if wildcardAppNames != [ ] || includeExtraHosts then
      ''
        ${mkEntryPointAddress scheme "*.${cfg.domain}"} {
        ${body}
        }
      ''
    else
      "";

  forbiddenPageHtml = pkgs.writeText "homelab-403.html" ''
    <!DOCTYPE html>
    <html lang="en">
    <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>403 Forbidden</title>
    <style>
      @font-face {
        font-family: "Inter";
        font-weight: 100 900;
        font-style: normal;
        font-display: swap;
        src: url("/__403-assets__/inter-var.ttf") format("truetype-variations");
      }

      * { box-sizing: border-box; }
      html, body { height: 100%; margin: 0; }
      body {
        position: relative;
        overflow: hidden;
        display: flex;
        align-items: center;
        justify-content: center;
        min-height: 100dvh;
        padding: 1.25rem;
        background: radial-gradient(circle at 50% 30%, #1a1210 0%, #0a0a0c 60%);
        font-family: "Inter", sans-serif;
        color: #e6e6e6;
      }
      body::before {
        content: "";
        position: absolute;
        inset: 0;
        background-image: radial-gradient(rgba(255, 255, 255, 0.08) 1px, transparent 1px);
        background-size: 26px 26px;
        mask-image: radial-gradient(circle at 60% 45%, black 0%, transparent 90%);
        -webkit-mask-image: radial-gradient(circle at 60% 45%, black 0%, transparent 90%);
        pointer-events: none;
      }
      .ghost-number {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -52%);
        font-size: clamp(18rem, 36vw, 56rem);
        font-weight: 700;
        line-height: 1;
        color: #f5a35c;
        opacity: 0.06;
        white-space: nowrap;
        user-select: none;
        pointer-events: none;
      }
      .card {
        position: relative;
        z-index: 1;
        overflow: hidden;
        text-align: center;
        padding: 3.5rem 4rem;
        width: 100%;
        max-width: 32rem;
        border-radius: 20px;
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-top-color: rgba(255, 255, 255, 0.18);
        background: #100b09e6;
        backdrop-filter: blur(24px);
        -webkit-backdrop-filter: blur(24px);
        box-shadow: 0 24px 70px rgba(0, 0, 0, 0.6);
        animation: fadeInUp 0.7s ease-out both;
      }
      .card::before {
        content: "";
        position: absolute;
        top: 0;
        left: 0;
        width: 55%;
        height: 55%;
        background: radial-gradient(ellipse at top left, rgba(255, 255, 255, 0.07), transparent 70%);
        pointer-events: none;
      }
      .card > * { position: relative; }
      .icon-wrap {
        position: relative;
        width: 72px;
        height: 72px;
        margin: 0 auto 1.75rem;
        display: flex;
        align-items: center;
        justify-content: center;
      }
      .icon-glow {
        position: absolute;
        inset: -16px;
        border-radius: 50%;
        background: radial-gradient(circle, rgba(245, 163, 92, 0.32) 0%, transparent 72%);
        filter: blur(6px);
        animation: pulseGlow 3.5s ease-in-out infinite;
      }
      .icon {
        position: relative;
        width: 42px;
        height: 42px;
        color: #f5a35c;
        filter: drop-shadow(0 0 10px rgba(245, 163, 92, 0.45));
      }
      .eyebrow {
        font-size: 0.8rem;
        font-weight: 600;
        letter-spacing: 0.2em;
        text-transform: uppercase;
        color: #f5a35c;
        margin: 0 0 1rem;
      }
      h1 {
        margin: 0 0 1rem;
        font-size: 4.5rem;
        font-weight: 700;
        letter-spacing: -0.03em;
        color: #f5f5f5;
      }
      p.desc {
        margin: 0;
        font-size: 1.1rem;
        font-weight: 400;
        color: #9a9a9a;
      }

      @media (max-width: 900px) {
        .ghost-number { display: none; }
      }
      @media (max-width: 640px) {
        .card { padding: 2.75rem 2rem; border-radius: 16px; }
        h1 { font-size: 3.25rem; }
        p.desc { font-size: 1rem; }
      }
      @media (max-width: 400px) {
        body { padding: 1rem; }
        .card { padding: 2.25rem 1.5rem; }
        .icon-wrap { width: 60px; height: 60px; margin-bottom: 1.25rem; }
        .icon { width: 36px; height: 36px; }
        .eyebrow { font-size: 0.7rem; margin-bottom: 0.75rem; }
        h1 { font-size: 2.5rem; margin-bottom: 0.75rem; }
        p.desc { font-size: 0.95rem; }
      }
      @media (max-height: 480px) {
        .card { padding: 1.75rem 2rem; }
        .icon-wrap { width: 52px; height: 52px; margin-bottom: 1rem; }
        .icon { width: 30px; height: 30px; }
        h1 { font-size: 2.25rem; margin-bottom: 0.5rem; }
        .eyebrow { margin-bottom: 0.5rem; }
      }

      @keyframes pulseGlow {
        0%, 100% { opacity: 0.6; transform: scale(1); }
        50% { opacity: 1; transform: scale(1.15); }
      }
      @keyframes fadeInUp {
        from { opacity: 0; transform: translateY(12px); }
        to { opacity: 1; transform: translateY(0); }
      }
      @media (prefers-reduced-motion: reduce) {
        .icon-glow, .card { animation: none; }
      }
    </style>
    </head>
    <body>
      <div class="ghost-number" aria-hidden="true">403</div>
      <div class="card">
        <div class="icon-wrap">
          <div class="icon-glow"></div>
          <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
            <circle cx="12" cy="12" r="9"/>
            <line x1="5.5" y1="18.5" x2="18.5" y2="5.5"/>
          </svg>
        </div>
        <p class="eyebrow">Error 403</p>
        <h1>Forbidden</h1>
        <p class="desc">You don't have permission to access this resource.</p>
      </div>
    </body>
    </html>
  '';

  forbiddenPageDir = pkgs.runCommand "homelab-403-page" { } ''
    mkdir -p $out/__403-assets__
    cp ${forbiddenPageHtml} $out/403.html
    cp ${pkgs.inter}/share/fonts/truetype/InterVariable.ttf $out/__403-assets__/inter-var.ttf
  '';

  forbiddenSnippet = ''
    (forbidden_403) {
      handle_errors 403 {
        root * /srv/errors
        rewrite * /403.html
        file_server
      }
    }'';

  caddyfile = pkgs.writeText "homelab-Caddyfile" ''
    ${cfg.caddy.globalConfig}
    ${forbiddenSnippet}
    ${mkWildcardBlock "https"}
    ${concatStringsSep "\n" (map (mkVirtualHost "https") otherAppNames)}
    ${mkWildcardBlock "http"}
    ${concatStringsSep "\n" (map (mkVirtualHost "http") otherAppNames)}
  '';

  parsePort =
    portStr:
    let
      protoParts = lib.splitString "/" portStr;
      proto = if lib.length protoParts > 1 then lib.last protoParts else "tcp";
      segments = lib.splitString ":" (lib.head protoParts);
      hasHostAddress = lib.length segments >= 3;
      hostAddress = if hasHostAddress then lib.elemAt segments (lib.length segments - 3) else null;
      hostPort =
        if lib.length segments >= 2 then
          lib.toInt (lib.elemAt segments (lib.length segments - 2))
        else
          lib.toInt (lib.head segments);
    in
    {
      inherit proto hostPort hostAddress;
    };

  loopbackTunnelPortMapping = "127.0.0.1:${toString tunnelPort}:${toString tunnelPort}";
  containerPorts = lib.unique ([ loopbackTunnelPortMapping ] ++ cfg.caddy.ports);
  parsedPorts = map parsePort containerPorts;
  externallyBoundPorts = lib.filter (
    e:
    e.hostAddress == null
    || !(builtins.elem e.hostAddress [
      "127.0.0.1"
      "::1"
    ])
  ) parsedPorts;
  firewallTCPPorts = lib.unique (
    map (e: e.hostPort) (lib.filter (e: e.proto == "tcp") externallyBoundPorts)
  );
  firewallUDPPorts = lib.unique (
    map (e: e.hostPort) (lib.filter (e: e.proto == "udp") externallyBoundPorts)
  );
in
{
  config = mkIf (cfg.enable && cfg.caddy.enable) {
    homelab.caddy = {
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
      requires = [ "${networkUnitName}.service" ];
      after = [ "${networkUnitName}.service" ];
    };

    networking.firewall = mkIf cfg.caddy.openFirewall {
      allowedTCPPorts = firewallTCPPorts;
      allowedUDPPorts = firewallUDPPorts;
    };

    virtualisation.oci-containers.containers."caddy" = {
      image = cfg.caddy.image;
      autoStart = true;
      ports = containerPorts;
      environment = cfg.caddy.environment;
      environmentFiles = cfg.caddy.environmentFiles;
      volumes = [
        "${caddyfile}:/etc/caddy/Caddyfile:ro"
        "${forbiddenPageDir}:/srv/errors:ro"
        "${cfg.dataDir}/caddy/data:/data"
        "${cfg.dataDir}/caddy/config:/config"
      ]
      ++ cfg.caddy.extraVolumes;
      networks = [ cfg.ingressNetwork ];
    };
  };
}
