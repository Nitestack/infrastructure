{
  config,
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

  homestation.homelab.caddy.extraHosts = ''
    @nextcloud-aio host ${nextcloudAioHost}
    handle @nextcloud-aio {
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
      targetService = "master";
      caddyDirectives = ''
        header Strict-Transport-Security max-age=31536000;
      '';
    };

    services.master = {
      enable = true;
      # Intentionally unpinned: AIO reads its own image tag at runtime to derive the channel
      # for all child images it spawns, and its bundled watchtower self-updates the
      # mastercontainer. Pinning a digest breaks both mechanisms. See:
      # https://github.com/nextcloud/all-in-one#how-to-properly-update-nextcloud-all-in-one
      image = "ghcr.io/nextcloud-releases/all-in-one:latest";
      containerName = "nextcloud-aio-mastercontainer";
      port = 11000;

      environment = {
        APACHE_PORT = "11000";
        APACHE_IP_BINDING = "0.0.0.0";
        APACHE_ADDITIONAL_NETWORK = cfg.ingressNetwork;
        SKIP_DOMAIN_VALIDATION = "false";
        NEXTCLOUD_DATADIR = nextcloudDataDir;
      };

      volumes = [
        {
          type = "volume";
          volume = "nextcloud_aio_mastercontainer";
          engineName = "nextcloud_aio_mastercontainer";
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
