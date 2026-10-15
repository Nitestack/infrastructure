{
  config,
  ...
}:
let
  cfg = config.homelab;
  port = 8090;
in
{
  # UpSnap needs host networking for LAN broadcasts. A host-network service
  # cannot join Caddy's Docker ingress network, so proxy it like AdGuard.
  # extraHosts only handles local HTTPS; the Cloudflare tunnel returns 403.
  homelab.caddy.extraHosts = ''
    @power host power.${cfg.domain}
    handle @power {
      reverse_proxy ${cfg.lanAddress}:${toString port}
    }
  '';

  homelab.apps.upsnap.services.web = {
    enable = true;
    image = "seriousm4x/upsnap:5.7.2@sha256:1e7c2345c493f9228a5dc2102be06b5a33331100f303fe0078502f4ef1068724";

    privileges = {
      networkMode = "host";
      capabilities = {
        add = [ "NET_RAW" ];
        drop = [ "ALL" ];
      };
    };
    runtime.user = "1000:1000";
    helpers.timezone = true;

    environment = {
      # The LAN listener is reached only by Caddy's Docker bridge through
      # the firewall rule below; port 8090 is not opened to LAN clients.
      UPSNAP_HTTP_LISTEN = "${cfg.lanAddress}:${toString port}";
      UPSNAP_SCAN_RANGE = "192.168.178.0/24";
    };

    volumes = [
      {
        source = "data";
        target = "/app/pb_data";
        owner = "1000";
        group = "1000";
        mode = "0750";
      }
    ];

    healthcheck = {
      test = [
        "CMD-SHELL"
        "curl -fsS http://${cfg.lanAddress}:${toString port}/api/health >/dev/null"
      ];
      interval = "60s";
    };

    extraServiceConfig.security_opt = [ "no-new-privileges:true" ];
  };

  # Caddy connects from its Docker bridge to the host-network listener.
  # Do not add 8090 to allowedTCPPorts: it must stay unavailable from LAN.
  networking.firewall.extraInputRules = ''
    iifname "br-*" ip daddr ${cfg.lanAddress} tcp dport ${toString port} accept
  '';
}
