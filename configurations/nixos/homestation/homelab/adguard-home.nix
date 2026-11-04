{
  config,
  ...
}:
let
  cfg = config.homelab;
  webPort = 3000;
  webAddress = "${cfg.lanAddress}:${toString webPort}";
in
{
  homelab.caddy.extraHosts = ''
    @dns host dns.${cfg.domain}
    handle @dns {
      reverse_proxy ${webAddress}
    }
  '';

  services.adguardhome = {
    enable = true;
    mutableSettings = false;
    openFirewall = false;
    settings = {
      http.address = webAddress;

      dns = {
        bind_hosts = [
          "0.0.0.0"
          "::"
        ];
        ratelimit = 0;
        upstream_dns = [
          "https://cloudflare-dns.com/dns-query"
          "https://dns.google/dns-query"
        ];
        upstream_mode = "parallel";
        upstream_timeout = "3s";
        bootstrap_dns = [
          "1.1.1.1"
          "8.8.8.8"
        ];
        fallback_dns = [
          "1.1.1.1"
          "8.8.8.8"
        ];
        local_ptr_upstreams = [
          "192.168.178.1"
        ];
      };

      filtering = {
        protection_enabled = true;
        filtering_enabled = true;
        parental_enabled = false;
        safe_search.enabled = false;
      };

      filters = [
        {
          enabled = true;
          url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/pro.plus.txt";
        }
        {
          enabled = true;
          url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/tif.medium.txt";
        }
        {
          enabled = true;
          url = "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareAdGuardHome.txt";
        }
      ];
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];

    # Permit Docker containers to reach AdGuard's admin UI.
    # Do not expose port 3000 generally to the LAN.
    extraInputRules = ''
      iifname "br-*" tcp dport ${toString webPort} accept
    '';
  };
}
