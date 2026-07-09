{
  config,
  lib,
  ...
}:
let
  cfg = config.homestation.homelab;
  username = config.meta.username;
  homelab-lib = import ../../../../modules/nixos/homestation-homelab/lib.nix {
    inherit cfg lib;
  };
  calibreWebAutomated = cfg.apps.calibre-web-automated;
in
{
  homestation.homelab.apps.shelfmark = {
    enable = calibreWebAutomated.enable;

    expose = {
      mode = "public";
      host = "books";
    };

    services.web = {
      enable = true;
      image = "ghcr.io/calibrain/shelfmark:v1.3.0@sha256:22ca17919d5f663fd1b88f84c3ffd96339dc3aa60b9b3257726f3b7e6510412a";
      port = 8084;

      helpers.userIds = true;

      environment = {
        DOCKERMODE = "true";
        ONBOARDING = "false";
        CALIBRE_WEB_URL = "https://${homelab-lib.effectiveHost calibreWebAutomated}";
        BOOK_LANGUAGE = "en,de";
        SEARCH_MODE = "universal";
        METADATA_PROVIDER = "hardcover";
        METADATA_PROVIDER_AUDIOBOOK = "hardcover";
        EMAIL_SMTP_HOST = cfg.smtp.host;
        EMAIL_SMTP_PORT = toString cfg.smtp.port;
        EMAIL_SMTP_SECURITY = cfg.smtp.security;
        EMAIL_SMTP_USERNAME = cfg.smtp.username;
        EMAIL_FROM = cfg.smtp.from;
        PROWLARR_ENABLED = "true";
        PROWLARR_URL = "https://index.${cfg.domain}";
        PROWLARR_TORRENT_CLIENT = "qbittorrent";
        QBITTORRENT_URL = "https://magnets.${cfg.domain}";
        QBITTORRENT_DOWNLOAD_DIR = "/data/downloads";
        HARDCOVER_ENABLED = "true";
      };

      environmentFiles = [ config.sops.templates."shelfmark.env".path ];

      volumes = [
        {
          type = "bind";
          source = "${cfg.dataDir}/calibre-web-automated/upload";
          target = "/books";
        }
        {
          type = "bind";
          source = "config";
          target = "/config";
          owner = username;
          group = "users";
        }
        {
          # Target must match rdtclient's internal container path (/data/downloads) so that
          # shelfmark can resolve the exact paths rdtclient reports for completed downloads.
          type = "bind";
          source = "${cfg.dataDir}/rdtclient/downloads";
          target = "/data/downloads";
        }
      ];

      healthcheck = {
        test = [
          "CMD"
          "curl"
          "-sf"
          "http://localhost:8084/api/health"
        ];
        interval = "30s";
        timeout = "30s";
        retries = 3;
      };
    };
  };
}
