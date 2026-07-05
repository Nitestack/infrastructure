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

  indentLines =
    prefix: text:
    concatStringsSep "\n" (
      map (line: optionalString (line != "") prefix + line) (
        builtins.filter (line: line != "") (lib.splitString "\n" text)
      )
    );

  mkReverseProxy =
    service:
    let
      upstream =
        if service.caddy.upstream != null then
          service.caddy.upstream
        else
          "${service.containerName}:${toString service.expose.port}";
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

  mkVirtualHost = _: service: ''
    ${service.expose.host} {
    ${indentLines "  " service.caddy.extraConfig}
    ${mkReverseProxy service}
    }
  '';

  caddyfile = pkgs.writeText "homelab-Caddyfile" ''
    ${cfg.caddy.globalConfig}
    ${concatStringsSep "\n" (mapAttrsToList mkVirtualHost enabledHttpServices)}
  '';
in
{
  config = mkIf (cfg.enable && cfg.caddy.enable) {
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
