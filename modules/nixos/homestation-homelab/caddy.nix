{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    concatStringsSep
    filterAttrs
    mapAttrsToList
    mkIf
    optionalString
    ;

  cfg = config.homestation.homelab;

  enabledHttpServices = filterAttrs (
    _: service:
    service.enable
    && service.caddy.enable
    && service.expose.mode != "none"
    && service.expose.protocol == "http"
  ) cfg.services;

  hasHttpServices = enabledHttpServices != { };
  runCaddy = cfg.caddy.enable && (cfg.caddy.enableWithoutServices || hasHttpServices);

  indentLines =
    prefix: text:
    concatStringsSep "\n" (
      map (line: optionalString (line != "") prefix + line) (
        builtins.filter (line: line != "") (lib.splitString "\n" text)
      )
    );

  mkReverseProxy =
    name: service:
    let
      upstream =
        if service.caddy.upstream != null then
          service.caddy.upstream
        else
          "${name}:${toString service.expose.port}";
      proxyExtra = indentLines "    " service.caddy.reverseProxyExtraConfig;
    in
    if service.caddy.reverseProxyExtraConfig == "" then
      "  reverse_proxy ${upstream}"
    else
      ''
        reverse_proxy ${upstream} {
        ${proxyExtra}
        }
      '';

  mkVirtualHost = name: service: ''
    ${service.expose.host} {
    ${indentLines "  " service.caddy.extraConfig}
    ${mkReverseProxy name service}
    }
  '';

  caddyfile = pkgs.writeText "homelab-Caddyfile" ''
    ${cfg.caddy.globalConfig}
    ${concatStringsSep "\n" (mapAttrsToList mkVirtualHost enabledHttpServices)}
  '';
in
{
  config = mkIf (cfg.enable && runCaddy) {
    networking.firewall = mkIf cfg.caddy.openFirewall {
      allowedTCPPorts = cfg.caddy.firewall.allowedTCPPorts;
      allowedUDPPorts = cfg.caddy.firewall.allowedUDPPorts;
    };

    virtualisation.oci-containers.containers.${cfg.caddy.containerName} = {
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
      networks = [ cfg.network.name ];
      dependsOn = builtins.attrNames enabledHttpServices;
    };
  };
}
