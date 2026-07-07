{
  config,
  lib,
  ...
}:
let
  cfg = config.homestation.homelab;
  nextcloudHost = "cloud.${cfg.domain}";
  nextcloudAioHost = "nextcloud-aio.${cfg.domain}";
  nextcloudDataDir = "${cfg.dataDir}/nextcloud/data";
in
{
  systemd.tmpfiles.rules = [
    "d ${nextcloudDataDir} 0755 root root -"
  ];

  homestation.homelab.dns.records = lib.mkIf (cfg.domain != null && cfg.lanAddress != null) {
    ${nextcloudAioHost} = {
      type = "A";
      value = cfg.lanAddress;
      visibility = "lan";
    };
  };

  homestation.homelab.caddy.extraSiteBlocks = lib.mkIf (cfg.domain != null) ''
    ${nextcloudAioHost} {
      reverse_proxy https://nextcloud-aio-mastercontainer:8080 {
        transport http {
          tls_insecure_skip_verify
        }
      }
    }
  '';

  homestation.homelab.apps.nextcloud = {
    expose = {
      mode = "public";
      host = "cloud";
      service = "master";
    };

    routes = [
      {
        upstream.service = "master";
        extraConfig = ''
          header Strict-Transport-Security max-age=31536000;
        '';
      }
    ];

    services.master = {
      enable = true;
      image = "ghcr.io/nextcloud-releases/all-in-one:latest";
      containerName = "nextcloud-aio-mastercontainer";
      port = 11000;

      environment = {
        APACHE_PORT = "11000";
        APACHE_IP_BINDING = "0.0.0.0";
        APACHE_ADDITIONAL_NETWORK = cfg.edgeNetwork.name;
        SKIP_DOMAIN_VALIDATION = "false";
        NEXTCLOUD_DATADIR = nextcloudDataDir;
      };

      volumes = [
        {
          type = "volume";
          name = "nextcloud_aio_mastercontainer";
          dockerName = "nextcloud_aio_mastercontainer";
          target = "/mnt/docker-aio-config";
        }
        {
          type = "bind";
          source = "/var/run/docker.sock";
          target = "/var/run/docker.sock";
          readOnly = true;
        }
      ];

      extraServiceConfig = {
        init = true;
      };
    };
  };
}
