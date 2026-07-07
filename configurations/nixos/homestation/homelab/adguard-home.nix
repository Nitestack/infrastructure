{
  config,
  lib,
  ...
}:
let
  cfg = config.homestation.homelab;
  dnsHost = if cfg.domain != null then "dns.${cfg.domain}" else "dns";
  routerIds = [
    "192.168.178.1"
    "fd73:4cd4:b6c2:0:36e1:a9ff:feb4:31b8"
  ];
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
      clients.persistent = [
        {
          name = "Router";
          ids = routerIds;
          tags = [ "device_other" ];
        }
      ];
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
