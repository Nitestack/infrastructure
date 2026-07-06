{ config, ... }:
let
  domain = config.homestation.homelab.domain;
  mkUrl = host: "https://${host}.${domain}";
in
{
  homestation.homelab.apps.glance.container = {
    enable = true;
    image = "glanceapp/glance:latest@sha256:32ab73d80f2b8b5fb0735b0431deb36b93fbb6b2fb43592449b0178c8b83e350";

    expose = {
      mode = "public";
      host = "dash";
      port = 8080;
    };

    environment = {
      ADGUARD_HOME_URL = mkUrl "dns";
      ADVENTURE_LOG_URL = mkUrl "travel";
      BESZEL_URL = mkUrl "status";
      CALIBRE_WEB_AUTOMATED_URL = mkUrl "lib";
      ENTE_AUTH_URL = mkUrl "2fa";
      FRESHRSS_URL = mkUrl "feed";
      GHOSTFOLIO_URL = mkUrl "wealth";
      GLANCE_URL = mkUrl "dash";
      GROCY_URL = mkUrl "house";
      IMMICH_URL = mkUrl "media";
      IT_TOOLS_URL = mkUrl "it";
      NAVIDROME_URL = mkUrl "music";
      NEXTCLOUD_URL = mkUrl "cloud";
      POCKET_ID_URL = mkUrl "id";
      PROWLARR_URL = mkUrl "index";
      RDTCLIENT_URL = mkUrl "magnets";
      SHELFMARK_URL = mkUrl "books";
      VAULTWARDEN_URL = mkUrl "vault";
      WEALTHFOLIO_URL = mkUrl "wealth";
      WGER_URL = mkUrl "health";
      YAMTRACK_URL = mkUrl "track";
      ZEROBYTE_URL = mkUrl "backup";
    };

    environmentFiles = [ config.sops.secrets."glance/env".path ];

    volumes = [
      {
        source = "${./glance/home.yml}";
        target = "/app/config/home.yml";
        readOnly = true;
      }
      {
        source = "/var/run/docker.sock";
        target = "/var/run/docker.sock";
        readOnly = true;
      }
    ];
  };
}
