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

  homestation.homelab.caddy.extraSiteBlocks = lib.mkIf (cfg.domain != null && cfg.lanAddress != null) ''
    dns.${cfg.domain} {
      reverse_proxy ${cfg.lanAddress}:3000
    }
  '';

  services.adguardhome = {
    enable = true;
    mutableSettings = false;
    host = if cfg.lanAddress != null then cfg.lanAddress else "0.0.0.0";
    port = 3000;
    openFirewall = true;
    settings = {
      dns = {
        bind_hosts = lib.optional (cfg.lanAddress != null) cfg.lanAddress;
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
