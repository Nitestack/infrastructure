{
  config,
  ...
}:
let
  cfg = config.homelab;
  username = config.meta.username;
  inherit (cfg.lib) serviceUrl appUrl;
  calibreWebAutomated = cfg.apps.calibre-web-automated;
in
{
  homelab.apps.shelfmark = {
    enable = calibreWebAutomated.enable;

    expose = {
      mode = "public";
      host = "books";
    };

    services.web = {
      enable = true;
      image = "ghcr.io/calibrain/shelfmark:v1.3.3@sha256:b8ca861d8b832b8800739b7c7de4fbf93ace6657cf9a0c94a508e71f50913c1f";
      port = 8084;

      helpers.userIds = true;

      environment = {
        # Bootstrap Configuration
        DOCKERMODE = "true";
        ONBOARDING = "false";
        # General
        CALIBRE_WEB_URL = appUrl cfg.apps.calibre-web-automated;
        BOOK_LANGUAGE = "en,de";
        SEARCH_MODE = "universal";
        METADATA_PROVIDER = "hardcover";
        METADATA_PROVIDER_AUDIOBOOK = "hardcover";
        # Downloads
        EMAIL_SMTP_HOST = cfg.smtp.host;
        EMAIL_SMTP_PORT = toString cfg.smtp.port;
        EMAIL_SMTP_SECURITY = cfg.smtp.security;
        EMAIL_SMTP_USERNAME = cfg.smtp.username;
        EMAIL_FROM = cfg.smtp.from;
        # Security
        AUTH_METHOD = "oidc";
        OIDC_DISCOVERY_URL = "${appUrl cfg.apps.pocket-id}/.well-known/openid-configuration";
        OIDC_BUTTON_LABEL = "Pocket ID";
        HIDE_LOCAL_AUTH = "true";
        DISABLE_LOCAL_AUTH = "true";
        OIDC_AUTO_REDIRECT = "true";
        # Prowlarr
        PROWLARR_ENABLED = "true";
        PROWLARR_URL = serviceUrl "prowlarr" "web";
        PROWLARR_TORRENT_CLIENT = "qbittorrent";
        # Download Clients
        QBITTORRENT_URL = serviceUrl "rdtclient" "web";
        QBITTORRENT_DOWNLOAD_DIR = "/data/downloads";
        # Hardcover
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
