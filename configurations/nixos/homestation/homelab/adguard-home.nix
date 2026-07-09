{
  config,
  ...
}:
let
  cfg = config.homestation.homelab;
in
{
  homestation.homelab.caddy.extraHosts = ''
    @dns host dns.${cfg.domain}
    handle @dns {
      reverse_proxy ${cfg.lanAddress}:${toString config.services.adguardhome.port}
    }
  '';

  services.adguardhome = {
    enable = true;
    mutableSettings = false;
    openFirewall = true;
    settings = {
      dns = {
        bind_hosts = [
          cfg.lanAddress
          "::"
        ];
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
