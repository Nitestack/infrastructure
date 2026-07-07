{
  config,
  lib,
  ...
}:
let
  cfg = config.homestation.homelab;
  dnsHost = if cfg.domain != null then "dns.${cfg.domain}" else "dns";
in
{
  homestation.homelab.dns.records = lib.mkIf (cfg.lanAddress != null) (
    builtins.listToAttrs [
      {
        name = dnsHost;
        value = {
          type = "A";
          value = cfg.lanAddress;
          visibility = "lan";
        };
      }
    ]
  );

  homestation.homelab.caddy.extraSiteBlocks =
    lib.mkIf (cfg.domain != null && cfg.lanAddress != null)
      ''
        dns.${cfg.domain} {
          reverse_proxy ${cfg.lanAddress}:${toString config.services.adguardhome.port}
        }
      '';

  services.adguardhome = {
    enable = true;
    mutableSettings = false;
    openFirewall = true;
    settings = {
      dns = {
        bind_hosts = (lib.optional (cfg.lanAddress != null) cfg.lanAddress) ++ [ "::" ];
        port = 53;
        bootstrap_dns = [
          "1.1.1.1"
          "1.0.0.1"
        ];
      };
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };
}
