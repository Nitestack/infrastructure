{
  config,
  lib,
  ...
}:
let
  cfg = config.homestation.homelab;
  homelab-lib = import ../../../../modules/nixos/homestation-homelab/lib.nix {
    inherit cfg lib;
  };
  inherit (homelab-lib) effectiveHost;

  itTools = cfg.apps.it-tools;
  domain = cfg.domain;
  mkUrl = host: "https://${host}.${domain}";
  appUrl = app: "https://${effectiveHost app}";
  adguardHomeUrl = "https://dns.${domain}";
in
{
  homestation.homelab.apps.glance = {
    expose = {
      mode = "public";
      host = "dash";
    };

    services.web = {
      enable = true;
      image = "glanceapp/glance:latest@sha256:32ab73d80f2b8b5fb0735b0431deb36b93fbb6b2fb43592449b0178c8b83e350";
      port = 8080;

      environment = {
        ADGUARD_HOME_URL = adguardHomeUrl;
        ADVENTURE_LOG_URL = mkUrl "travel";
        BESZEL_URL = mkUrl "status";
        CALIBRE_WEB_AUTOMATED_URL = mkUrl "lib";
        ENTE_AUTH_URL = mkUrl "2fa";
        FRESHRSS_URL = mkUrl "feed";
        GLANCE_URL = mkUrl "dash";
        IMMICH_URL = mkUrl "media";
        IT_TOOLS_URL = appUrl itTools;
        NAVIDROME_URL = mkUrl "music";
        NEXTCLOUD_URL = mkUrl "cloud";
        POCKET_ID_URL = mkUrl "id";
        PROWLARR_URL = mkUrl "index";
        RDTCLIENT_URL = mkUrl "magnets";
        SHELFMARK_URL = mkUrl "books";
        VAULTWARDEN_URL = mkUrl "vault";
        WEALTHFOLIO_URL = mkUrl "wealth";
        YAMTRACK_URL = mkUrl "track";
        ZEROBYTE_URL = mkUrl "backup";
      };

      environmentFiles = [ config.sops.templates."glance.env".path ];

      volumes = [
        {
          type = "bind";
          source = "${./glance/home.yml}";
          target = "/app/config/home.yml";
          readOnly = true;
        }
        {
          type = "bind";
          source = "/var/run/docker.sock";
          target = "/var/run/docker.sock";
          readOnly = true;
        }
      ];
    };
  };
}
