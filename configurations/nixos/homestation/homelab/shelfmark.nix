{
  config,
  lib,
  ...
}:
let
  cfg = config.homestation.homelab;
  username = config.meta.username;
  userUid = config.users.users.${username}.uid;
  userGid = config.ids.gids.users;
  homelab-lib = import ../../../../modules/nixos/homestation-homelab/lib.nix {
    inherit cfg lib;
  };
  calibreWebAutomated = cfg.apps.calibre-web-automated.container;
in
{
  homestation.homelab.apps.shelfmark = {
    enable = calibreWebAutomated.enable;

    container = {
      enable = true;
      image = "ghcr.io/calibrain/shelfmark:v1.3.0@sha256:22ca17919d5f663fd1b88f84c3ffd96339dc3aa60b9b3257726f3b7e6510412a";

      expose = {
        mode = "public";
        host = "books";
        port = 8084;
      };

      environment = {
        DOCKERMODE = "true";
        ONBOARDING = "false";
        PUID = if userUid != null then toString userUid else "1000";
        PGID = toString userGid;
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
        HARDCOVER_ENABLED = "true";
      };

      environmentFiles = [ config.sops.templates."shelfmark.env".path ];

      volumes = [
        {
          source = "${cfg.dataDir}/calibre-web-automated/upload";
          target = "/books";
        }
        {
          source = "config";
          target = "/config";
          hostPath.user = username;
          hostPath.group = "users";
        }
        {
          source = "/mnt/data/rdtclient/downloads";
          target = "/mnt/data/rdtclient/downloads";
        }
      ];
    };
  };
}
